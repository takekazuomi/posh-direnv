============
posh-direnv
============

Inspired by direnv

https://github.com/direnv/direnv

posh-direnv is an environment switcher for the PowerShell. It executes ".psdirenv" in the current directory. You can easily set unique environment variables for each directory.

=====
Usage
=====

.. code-block:: posh

   $ mkdir work
   $ cd work
   $ Edit-DirEnvRc

Since notepad starts up, edit .psdirenv. When you exit the editor .psdirenv is applied.

.. code-block:: posh

   $ cat .\.psenvrc
   Write-Host "Hello posh-direnv"
   $Host.UI.RawUI.WindowTitle="posh-direnv"


Activate the new powershell and check its operation. If you move to a directory with .psdirenv, it will be displayed as below and the console title will be changed.

.. code-block:: posh

   $ cd work
   Hello posh-direnv

Once you exit the directory and move again. .psdirenv will not be executed. Re-execute with Set-DirEnvRc-Force.

Note
====
1. It does not support unload. Please note that changes to environment variables are cumulative.
2. ".psdirenv" is executed unconditionally. Please be aware that it may contain malicious code. Basically it is recommended not to put it in the public repository such as github.
