define apache::auth::sslcert (
  $ensure="present", 
  $cacert=false,
  $vhost,
  $location="/"){

  include apache::params
 

  if $cacert != false {
    $cacertfile = "${apache::params::root}/$vhost/ssl/$name-cacert.crt"
  }

  if $certchain != false {
    # The certificate chain file from your certification authority's. They
    # should inform you if you need one.
    file { $cacertfile:
      owner => "root",
	    group => "root",
	    mode  => 640,
	    source  => $cacert,
	    seltype => "cert_t",
	    notify  => Exec["apache-graceful"],
	    require => File["${apache::params::root}/${vhost}/ssl"],
    }
  }

  file {"${apache::params::root}/${vhost}/conf/${name}.conf":
    ensure => $ensure,
    content => template("apache/auth-sslcert.erb"),
    seltype => $operatingsystem ? {
      "RedHat" => "httpd_config_t",
      "CentOS" => "httpd_config_t",
      default  => undef,
    },
    notify => Exec["apache-graceful"],
  }


}
