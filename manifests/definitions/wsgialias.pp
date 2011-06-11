/*

== Definition: apache::wsgialias

Simple way of defining a wsgialias directive for a given virtualhost.

This definition will ensure all the required modules are loaded and will
drop a configuration snippet in the virtualhost's conf/ directory.

Parameters:
- *ensure*: present/absent.
- *location*: path in virtualhost's context to pass through using the ProxyPass
  directive.
- *wsgifile*: destination to which the ProxyPass directive points to.
- *vhost*: the virtualhost to which this directive will apply. Mandatory.
- *filename*: basename of the file in which the directive(s) will be put.
  Useful in the case directive order matters: apache reads the files in conf/
  in alphabetical order.

Requires:
- Class["apache"]
- matching Apache::Vhost[] instance

Example usage:

  apache::wsgialias { "01_fist_wsgi_alias":
    ensure    => present,
    location  => "/legacy/",
    filename  => "/var/wsgi/app.wsgi",
    vhost     => "www.example.com",
  }

*/
define apache::wsgialias (
  $ensure="present", 
  $location="", 
  $filename, 
  $vhost
) {

  $fname = regsubst($name, "\s", "_", "G")

  include apache::params

  if defined(Apache::Module["wsgi"]) {} else {
    apache::module {"wsgi": }
  }

  file { "${name} wsgialias on ${vhost}":
    ensure => $ensure,
    content => template("apache/wsgialias.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    name    => $filename ? {
      ""      => "${apache::params::root}/${vhost}/conf/wsgi-${fname}.conf",
      default => "${apache::params::root}/${vhost}/conf/${filename}",
    },
    notify  => Exec["apache-graceful"],
    require => Apache::Vhost[$vhost],
  }
}
