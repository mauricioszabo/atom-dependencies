# Dependencies

This is a simple package to be able to show dependencies on your code.

This package depends of a file, named **dependencies.json**, in the root of your project. With this, you can visualize your dependencies in a simple and clear manner.

To generate this package, it is necessary to run some code to do static analysis on your code or collect these informations on your test. In the **analyzers** directory there is an example of how to do this using Ruby on Rails and the ruby-prof gem.

You can click on any dependent object and see their dependencies too. For now, there's no way of navigating other than this.

![Dependency view](https://f.cloud.github.com/assets/69169/2290250/c35d867a-a017-11e3-86be-cd7c5bf3ff9b.gif)
