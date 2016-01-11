InstantRst
===========

:version: 0.9.8

..

    So, You'll see.

    -- InstantRst


A vim plugin for preview rst document instantly.

You can share the address through LAN too.
(And, You should note, all the navigation/edit inside your rst wiki will be show on that address,
if with ``InstantRst!``)

.. figure:: https://github.com/Rykka/github_things/raw/master/image/rst_quick_start.gif
    :align: center

    riv.vim_ (vim) +  InstantRst_ (web server) +  rhythm.css_ (theme)


----

This is an intro for vim usage.

To use only the server, see instant-rst.py_.

Install
-------

1. Vim with Vundle or NeoBundle:

   ``NeoBundle 'Rykka/InstantRst'``

2. Python:

.. code:: sh

   # Got some issue on pypi
   # sudo pip install instant-rst
   sudo pip install https://github.com/Rykka/instant-rst.py/archive/master.zip

3. Curl:

.. code:: sh

   sudo apt-get install curl

Commands
--------

Inside a rst buffer.


:InstantRst[!]
    Preview current buffer.
    Add ``!`` to  preview **ALL** rst buffer.

:StopInstantRst[!]
    Stop Preview current buffer
    Add ``!`` to  stop preview **ALL** rst buffer.
    


:NOTE: 

    If you find the server is still runnning after you stop it.

    You can find the process of ``instantRst`` and stop it manually.


Options
-------

g:instant_rst_slow
    Preview rst in fast or slow mode, default is ``0``.
    If your computer is a bit slow, set it to 1.

g:instant_rst_browser 
    Web browser for preview. default is ``''``.
    And then ``firefox`` will be used.

g:instant_rst_template
    Directory where the template for rendered pages is located.

    Defaults to using rhythm.css_, that is bundled with the server.

g:instant_rst_static
    Directory for static files used by the template.     
    To be used together with g:instant_rst_template
    
    Also defaults to the bundled rhythm.css_

g:instant_rst_port
    The port of webserver, default is ``5676``.

    Then the server is at ``http://localhost:5676`` 

    And you can open it at your lan ip too.

    If your vim is installed with '+py', then it will open at your lan ip.

    like ``http://192.168.1.123:5676``

g:instant_rst_localhost_only
    Only use localhost, and disable lan ip

    Whenever your vim has '+py'

g:instant_rst_forever 
    Always preview all rst buffer, default is ``0``.

g:instant_rst_bind_scroll
    Bind scroll with browser.

    When scrolling with Vim, The browser will scroll either.

    default is ``1``

g:instant_rst_additional_dirs
    Serve additional directories for previewing, default is an empty array ``[]``.

    For example: ``['/home/<my_user>/<my_rst_project>/images', '/home/<my_user>/<my_rst_project>/docs']``

    It requires the absolute path of the directory, and the last directory name is used in the server.

    A request made to ``/images/cats/1.png`` will try to serve the file from ``/home/<my_user>/<my_rst_project>/images/cats/1.png``


TODO
----

1. rst's inline image file contained are not displayed.

Related
-------

This plugin is for Riv.vim_.

which is a vim plugin for writing rst documents.

Issues
------
for debian user, you may need to install gevent manually

::

    sudo apt-get install libevent-dev
    sudo apt-get install python-all-dev
    sudo pip install greenlet
    sudo pip install gevent



CHANGELOG
---------

0.9.8
    add support for static file directory

License
-------

MIT

.. sectnum::
.. _riv.vim: https://github.com/Rykka/riv.vim
.. _typo.css: https://github.com/sofish/Typo.css
.. _instant-rst.py: https://github.com/rykka/instant-rst.py
.. _rhythm.css: https://github.com/Rykka/rhythm.css
.. _InstantRst: https://github.com/Rykka/InstantRst
