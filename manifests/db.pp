# = Define: postgresql::db
#
# This class create a database.
#
# == Parameters:
#
# [*dbname*]
#   Name of the database
#   (Default: $name)
#
# [*owner*]
#   Owner of the database. You have to create this user before.
#   (Default: $name)
#
# [*dbtemplate*]
#   Desired template. Blank
#   The name of the template from which to create the new database,
#   or blank ('') to use the default template.
#   (Default: '')
#
# [*encoding*]
#   Character set encoding to use in the new database.
#   (Default: '')
#
# [*lc_collate*]
#   Collation order (LC_COLLATE) to use in the new database.
#   (Default: '')
#
# [*lc_ctype*]
#   Character classification to use in the new database.
#   (Default: '')
#
# [*tablespace*]
#   The name of the tablespace that will be associated with the new database.
#   (Default: '')
#
# [*connection_limit*]
#   How many concurrent connections can be made to this database.
#   -1 (the default) means no limit.
#
# [*absent*]
#   Set to 'true' to remove database
#   (Default: false)
#
# == Example:
#
# * create database named "my_bd" owned by "my_bd"
#
#   postgresql::db { 'my_bd': }
#
# * create database named "my_bd" owned by "root"
#
#   postgresql::db { 'my_bd':
#     owner => 'root',
#   }
#
# * remove a database named 'my_bd'
#
#   postgresql::db { 'my_bd':
#     absent => true,
#   }
#
define postgresql::db(
  $dbname           = $name,
  $owner            = $name,
  $dbtemplate       = '',
  $encoding         = '',
  $lc_collate       = '',
  $lc_ctype         = '',
  $tablespace       = '',
  $connection_limit = '-1',
  $absent           = false
) {

  include 'postgresql'

  $bool_absent = any2bool($absent)

  $initial_query = "CREATE DATABASE \\\"${dbname}\\\" OWNER \\\"$owner\\\""
  $o_template = $dbtemplate ? {
    ''      => '',
    default => "TEMPLATE $dbtemplate",
  }
  $o_encoding = $encoding ? {
    ''      => '',
    default => "ENCODING $encoding",
  }
  $o_collate = $lc_collate ? {
    ''      => '',
    default => "LC_COLLATE $lc_collate",
  }
  $o_ctype= $lc_ctype ? {
    ''      => '',
    default => "LC_CTYPE $lc_ctype",
  }
  $o_tablespace = $tablespace ? {
    ''      => '',
    default => "TABLESPACE $tablespace",
  }
  $o_conn = $connection_limit ? {
    ''      => '',
    default => "CONNECTION LIMIT $connection_limit",
  }
  $opts = "$o_template $o_encoding $o_collate $o_ctype $o_tablespace $o_conn"
  $create_query = "$initial_query $opts;"
  $drop_query = "DROP DATABASE \\\"${dbname}\\\""

  $db_command = $bool_absent ? {
    true    => "echo \"$drop_query\" | psql",
    default => "echo \"$create_query\" | psql",
  }
  $cmd = "echo \\\\l|psql|tail -n +4|awk '{print \$1}'|grep '^${dbname}$'"
  $db_unless = $bool_absent ? {
    true  => undef,
    false => $cmd,
  }
  $db_onlyif = $bool_absent ? {
    true  => $cmd,
    false => undef,
  }
  $db_require = $bool_absent ? {
    true  => Package['postgresql'],
    false => [
      Package['postgresql'],
      Postgresql::Role[$owner]
    ],
  }

  exec { "postgres-manage-database-${name}":
    user    => $postgresql::process_user,
    path    => '/usr/bin:/bin:/usr/bin:/sbin',
    unless  => $db_unless,
    onlyif  => $db_onlyif,
    command => $db_command,
    require => $db_require,
  }
}
