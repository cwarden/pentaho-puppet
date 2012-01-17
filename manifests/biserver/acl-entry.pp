# Grant access to all files within a solution.
#
# Either a user or a role must be set.  Positions must be sequential and unique
# per resource.  TODO: automatically set position
#
# See acl-files in pentaho-solutions/system/pentaho.xml for the types of files which are protected by ACLs
# See http://bit.ly/wGDiCV for documentation on the PRO_FILES and PRO_ACLS_LIST tables
define pentaho::biserver::acl-entry($solution,
  $role = false,
  $user = false,
  $execute_perm = false,
  $subscribe_perm = false,
  $create_perm = false,
  $update_perm = false,
  $delete_perm = false,
  $grant_perm = false,
  $full_control = false,
  $position = 0) {

  if (($role and $user) or !($role or $user)) {
    fail('role OR user must be set, but not both')
  }
  if ($role) {
    $recipient_type = 1
    $recipient = $role
  } else {
    $recipient_type = 0
    $recipient = $user
  }

  Exec {
    path => [ '/usr/local/bin', '/usr/bin', '/bin' ]
  }

  $sql_tmpl = "<%
    if full_control then
      perms = -1
    else
      perms = 0
      if execute_perm   then perms += 1 end
      if subscribe_perm then perms += 2 end
      if create_perm    then perms += 4 end
      if update_perm    then perms += 8 end
      if delete_perm    then perms += 16 end
      if grant_perm     then perms += 32 end
    end
%>
BEGIN;
DELETE FROM
  acl
USING
  PRO_ACLS_LIST AS acl
INNER JOIN
  PRO_FILES AS files ON acl.ACL_ID = files.FILE_ID
WHERE
  files.fullPath REGEXP '/pentaho-solutions/<%= solution -%>(\$|/) AND
  RECIPIENT = <%= recipient -%>';
INSERT INTO
  PRO_ACLS_LIST
(ACL_ID, ACL_MASK, RECIP_TYPE, RECIPIENT, ACL_POSITION)
SELECT
  FILE_ID,
  <%= perms %>,
  <%= recipient_type %>,
  '<%= recipient %>',
  <%= position %>
FROM
  PRO_FILES
WHERE
  fullPath REGEXP '/pentaho-solutions/<%= solution -%>(\$|/)';
COMMIT;"
  $sql = inline_template($sql_tmpl)
  $sql_file = md5($sql)
  $sql_path = "/opt/pentaho/biserver-ce/data/puppet/acl-entry-${sql_file}.sql"

  file { "${sql_path}":
    owner   => 'root',
    mode    => '600',
    content => $sql,
  }

  exec { "create acl entry $title":
    command => "mysql -h ${pentaho::config::database_host} -u${pentaho::config::hibernate_user} -p${pentaho::config::hibernate_password} ${pentaho::config::hibernate_database} < ${sql_path} || rm -f $sql_path",
    refreshonly => false,
    subscribe => File[$sql_path],
   # subscribe => File[$sql_path, 'FILE_IDs']
  }
}
