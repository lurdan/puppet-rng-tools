include lsb

class { 'rng-tools':
  init_config => [ 'set HRNGDEVICE /dev/urandom', ],
}
