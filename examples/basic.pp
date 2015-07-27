# First, install a mysql server
class { '::mysql::server':
  # sahara documentation recommends this configuration.
  override_options   => {
    'mysqld' => {
      'max_allowed_packet' => '256M',
    },
  },

  # many configurations will need this line, too
  package_name       => 'mariadb-galera-server',

  # if you're installing into an existing openstack
  manage_config_file => false,
  purge_conf_dir     => false,
}

# Then, create a database
class { '::sahara::db::mysql':
  password => 'a_big_secret',
}

# And connect a message bus
class { '::sahara::notify::rabbitmq':
  rabbit_password => 'guest',
  rabbit_use_ssl  => false,
}

# Then the common class
class { '::sahara':
  database_connection => 'mysql://sahara:a_big_secret@127.0.0.1:3306/sahara',
  verbose             => true,
  debug               => true,
  admin_user          => 'admin',
  admin_password      => 'secrets_everywhere',
  admin_tenant_name   => 'admin',
  auth_uri            => 'http://127.0.0.1:5000/v2.0/',
  identity_uri        => 'http://127.0.0.1:35357/',
  host                => '0.0.0.0',
  port                => 8386,
  use_floating_ips    => true,
}

# Finally, make it accessible
class { '::sahara::keystone::auth':
  password => 'secrete',
}
