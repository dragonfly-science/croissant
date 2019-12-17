const modules = require.context('.', true, /\.js$/);
modules.keys().forEach(modules);
