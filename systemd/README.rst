How to manually install my_backup systemd services
==================================================

1. Copy the files in this directory to ``/etc/systemd/system/``::

    cp -i my_backup* /etc/systemd/system

2. If a custom config is going to be used, add ``-c FULL_PATH.conf`` to
   the ``ExecStart`` option in ``/etc/systemd/system/my_backup.service``.

3. Edit ``/etc/systemd/system/my_backup.timer`` to change the timer
   frequency and the persistent flag appropriately.

4. Edit ``/etc/systemd/system/my_backup-email-admin@.service`` to
   change the admin email.

5. Enable and start ``my_backup`` timer::

    # systemctl enable my_backup.timer
    # systemctl start my_backup.timer

6. Check that the timer is enabled::

    # systemctl list-timers



References
----------
https://www.freedesktop.org/software/systemd/man/systemd.service.html
https://wiki.gentoo.org/wiki/Systemd#Timer_services
