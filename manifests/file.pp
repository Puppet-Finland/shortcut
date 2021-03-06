#
# == Define: launcher::file
#
# Setup a shortcut file
#
# == Parameters
#
# [*user*]
#   The system user to add this desktop file for.
# [*command*]
#   The command this shortcut runs.
# [*icon*]
#   Name of the icon to use. Does not have to be a fully-qualified path.
# [*ensure*]
#   Ensure the resource is 'present' (default) or 'absent'.
# [*filename*]
#   Basename of the desktop file. Defaults to $title. Omit the .desktop 
#   extension.
# [*comment*]
#   Optional free-form comment/description for the desktop file.
# [*terminal*]
#   Determine if the command should be run in a terminal. Valid values 'true' 
#   and 'false' (default).
# [*type*]
#   Type of the desktop file. Defaults to 'Application'.
#
define launcher::file
(
    $user,
    $command,
    $icon,
    $ensure = 'present',
    $filename = $title,
    $comment = undef,
    $terminal = false,
    $type = 'Application'

)
{

    $applications_dir = "${::os::params::home}/${user}/.local/share/applications"

    # This is somewhat nasty technique, but creating a deep directory hierarchy
    # that has correct permissions using the File resource would be rather
    # challenging.
    exec { "launcher-create-${title}":
        command => "mkdir -p ${applications_dir}",
        user    => $user,
        path    => [ '/bin', '/usr/bin'],
        creates => $applications_dir,
        require => User[$user],
    }

    file { $filename:
        ensure  => $ensure,
        name    => "${::os::params::home}/${user}/.local/share/applications/${filename}.desktop",
        content => template('launcher/file.erb'),
        owner   => $::os::params::adminuser,
        group   => $::os::params::admingroup,
        mode    => '0644',
        require => Exec["launcher-create-${title}"],
    }
}
