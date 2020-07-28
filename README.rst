============
posh-direnv
============

Inspired by direnv

https://github.com/direnv/direnv

posh-direnv is an environment switcher for the PowerShell. It executes ".psdirenv" in the current directory. You can easily set unique environment variables for each directory.

==============
How to install
==============
You can install from PowerShell Gallery. `posh-direnv <https://www.powershellgallery.com/packages/posh-direnv>`_

.. code-block:: posh

   $ Install-Module -Name posh-direnv

=====
Usage
=====

.. code-block:: posh

   $ mkdir work
   $ cd work
   $ Edit-DirEnvRc

Since notepad starts up, edit .psdirenv. When you exit the editor .psdirenv is authorised and applied if the file was modified.

.. code-block:: posh

   $ cat .\.psenvrc
   Write-Host "Hello posh-direnv"
   $Host.UI.RawUI.WindowTitle="posh-direnv"


Activate the new powershell and check its operation. If you move to a directory with .psdirenv, it will be displayed as below and the console title will be changed.

.. code-block:: posh

   $ cd work
   psenvdir: loading work/.psenvrc
   Hello posh-direnv
   psenvdir: export

Once you exit the directory tree and move again the environment changes will be reversed and reapplied if you reenter the directory.

If you edit the .psenvrc file yourself or move it between directories you must authorise it before it will be applied.

.. code-block:: posh

   $ cd work
   psenvdir: work/.psenvrc not in allow list
   $ Approve-DirEnvRc
   psenvdir: loading work/.psenvrc
   Hello posh-direnv
   psenvdir: export

You can unauthorise a .psenvrc file by calling Deny-DirEnvRc and cleanup the authorised list in the event directories are deleted before being denied by calling Repair-DirEnvAuth.
