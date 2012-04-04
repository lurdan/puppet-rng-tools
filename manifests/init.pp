# require lsb
class rng-tools (
  $active = true,
  $device = '/dev/hwrng',
  $options = ''
) {

  $svc_name = $::operatingsystem ? {
    /(?i-mx:debian|ubuntu)/ => 'rng-tools',
    /(?i-mx:redhat|centos)/ => 'rngd',
  }

  package { 'rng-tools':
    name => $::operatingsystem ? {
      /(?i-mx:redhat|centos)/ => $::lsbmajdistrelease ? {
        '5' => 'rng-utils',
        default => 'rng-tools',
      },
      default => 'rng-tools',
    },
    require => Package['lsb'],
  }

  case $::operatingsystem {
    /(?i-mx:debian|ubuntu)/: {
      sysvinit::init::config { 'rng-tools':
        changes => "set HRNGDEVICE \'$device\'\nset RNGDOPTIONS \'$options\'",
        notify => Service['rng-tools'],
      }
    }
    /(?i-mx:redhat|centos)/: {
      file {
        '/etc/sysconfig/rng-tools':
          content => "HRNGDEVICE=$device\n",
          before => Package['rng-tools'],
          notify => Service['rng-tools'];
        '/etc/init.d/rng-tools':
          mode => 755,
          source => 'puppet:///modules/rng-tools/init',
          require => Package['rng-tools'],
          notify => Service['rng-tools'];
      }
    }
  }

  service { 'rng-tools':
    ensure => $active ? {
      true => running,
      default => stopped,
    },
    enable => $active,
    require => Package['rng-tools'],
  }
}
