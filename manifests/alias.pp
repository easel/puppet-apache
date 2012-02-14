/*

== Definition: apache::alias

Convenient way to declare an directive and corresponding directory permissions 
in a virtualhost context.

Parameters:
- *ensure*: present/absent.
- *vhost*: the virtualhost to which this directive will apply. Mandatory.
- *filename*: basename of the file in which the directive(s) will be put.
  Useful in the case directive order matters: apache reads the files in conf/
  in alphabetical order.
- *alias*: the base path of the alias ie /alias/
- *path*: the base path of the corresponding directory ie /var/www/alias/

Requires:
- Class["apache"]
- matching Apache::Vhost[] instance

Example usage:

  apache::alias { "/alias/":
    vhost => "www.example.com",
    path => "/var/www/alias"
  }

*/
define apache::alias($ensure="present", $filename="", $vhost, $path) {
  $clean_name = regsubst($name, "/", "", "G")

  include apache::params

  file { "${clean_name} alias on ${vhost}":
    ensure  => $ensure,
    content => "# file managed by puppet\n
<Directory ${path}>
   Order allow,deny
   Allow from all
</Directory>
Alias ${name} ${path}
",
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    name    => $filename ? {
      ""      => "${apache::params::root}/${vhost}/conf/alias-${clean_name}.conf",
      default => "${apache::params::root}/${vhost}/conf/${filename}",
    },
    notify  => Exec["apache-graceful"],
    require => Apache::Vhost[$vhost],
  }
}
