describe('sidenav', function() {
  it('expands and collapses subnavs', function() {
    var root = createDom('div', {},
      createDom('ul', {},
        createDom('li', { className: 'has_submenu li_one' }),
        createDom('li', { className: 'has_submenu li_two' })
      ));

    Bookwatch.startSidenav(root);
    var li = root.querySelector('.li_two');
    clickEl(li);

    expect(li.className).toContain('expanded');

    clickEl(li);

    expect(li.className).not.toContain('expanded');
  });

  it('does not expand or collapse subnav when a child link is clicked', function() {
    var root = createDom('div', {},
      createDom('ul', {},
        createDom('li', { className: 'has_submenu li_one' },
          createDom('a', { href: '#' }))
      ));

    Bookwatch.startSidenav(root);
    var li = root.querySelector('.li_one');
    var link = root.querySelector('a');
    clickEl(link);

    expect(li.className).not.toContain('expanded');

    clickEl(li);
    expect(li.className).toContain('expanded');

    clickEl(link);
    expect(li.className).toContain('expanded');

    clickEl(li);
    expect(li.className).not.toContain('expanded');
  });

  it('does not try to expand when there is no subnav', function() {
    var root = createDom('div', {},
      createDom('ul', {},
        createDom('li', {})));

    Bookwatch.startSidenav(root);
    var li = root.querySelector('li');
    clickEl(li);

    expect(li.className).not.toContain('expanded');
  });

  it('expands and collapses nested subnavs', function() {
    var root = createDom('div', {},
      createDom('ul', {},
        createDom('li', { className: 'has_submenu li_one' },
          createDom('ul', {},
            createDom('li', {className: 'has_submenu li_child'}))),
        createDom('li', { className: 'has_submenu li_two' })
      ));

    Bookwatch.startSidenav(root);
    var li = root.querySelector('.li_child');
    clickEl(li);

    expect(li.className).toContain('expanded');

    clickEl(li);

    expect(li.className).not.toContain('expanded');
  });

  it('highlights the active page', function() {
    var root = createDom('div', {},
      createDom('ul', {},
        createDom('li', {},
          createDom('a', { href: '/foo/bar/baz.html'})),
        createDom('li', {},
          createDom('a', { href: '/foo/bir/biz.html'})),
        createDom('li', {},
          createDom('a', { href: '/fob/bar/baz.html'})),
        createDom('li', {},
          createDom('a', { href: '/bar/baz.html'}))
      ));

    Bookwatch.startSidenav(root, '/fob/bar/baz.html');

    expect(root.querySelectorAll('a')[2].className).toContain('active');
  });

  it('ignores the path if it is not in the subnav', function() {
    var root = createDom('div', {},
      createDom('ul', {},
        createDom('li', {},
          createDom('a', { href: '/foo/bar/baz.html'})),
        createDom('li', {},
          createDom('a', { href: '/foo/bir/biz.html'}))
      ));

    Bookwatch.startSidenav(root, '/fob/bar/baz.html');

    expect(root.querySelector('a.active')).toBeNull();
  });

  it('expands the parent element when the current path is nested', function() {
    var root = createDom('div', {},
      createDom('ul', {},
        createDom('li', {className: 'has_submenu li_collapsed'}),
        createDom('li', {className: 'has_submenu li_grandparent'},
          createDom('a', {href: '/foo/bar/baz.html'}),
          createDom('ul', {},
            createDom('li', {className: 'has_submenu li_parent'},
              createDom('a', {href: '/bar/baz.html'}),
              createDom('ul', {},
                createDom('li', {},
                  createDom('a', {href: '/bar/foo/baz.html'}))
              ))))));


    Bookwatch.startSidenav(root, '/bar/foo/baz.html');
    expect(root.querySelector('.li_grandparent').className).toContain('expanded');
    expect(root.querySelector('.li_parent').className).toContain('expanded');

    expect(root.querySelector('.li_collapsed').className).not.toContain('expanded');
  });

  it('does not break with no subnav', function() {
    expect(function() {
      Bookwatch.startSidenav(null, 'bar/foo/baz.html');
    }).not.toThrow();
  });

  it('hides and shows main menu', function() {
    var root = createDom('div', {},
      createDom('div', { className: 'parent' },
        createDom('div', { className: 'clicker', 'data-behavior': 'MenuMobile' })));

    Bookwatch.mobileMainMenu(root);

    var parent = root.querySelector('.parent');
    var clicker = root.querySelector('.clicker');

    clickEl(clicker);

    expect(parent.className).toContain('menu-active');

    clickEl(clicker);

    expect(parent.className).not.toContain('menu-active');
  });

  it('hides and shows side nav', function() {
    var root = createDom('div', {},
      createDom('div', { className: 'parent' },
        createDom('div', { className: 'clicker', 'data-behavior': 'SubMenuMobile' })));

    Bookwatch.mobileSubMenu(root);

    var parent = root.querySelector('.parent');
    var clicker = root.querySelector('.clicker');

    clickEl(clicker);

    expect(parent.className).toContain('active');

    clickEl(clicker);

    expect(parent.className).not.toContain('active');
  });
});
