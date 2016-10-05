const NODE_ENV = process.env.NODE_ENV || 'development';

module.exports = {
    entry: './ohranatruda.in.ua/test/templates/iview/js/scripts_es6.js',

    output: {
        filename: './ohranatruda.in.ua/test/templates/iview/js/scripts.js'
    },

    /*plugins: NODE_ENV === 'production' ? [
        new webpack.optimize.UglifyJsPlugin({
            compress: {
                warnings: false,
                drop_console: true,
                unsafe: true
            }
        })
    ] : [
        new CopyWebpackPlugin([{
            from: './dev/index.html', to: './dist/index.html'
        },{
            from: './dev/css/style.css', to: './dist/css/style.css'
        }])
    ],*/

    module: {
        loaders: [
            { test: /\.js$/, loader: "babel?presets[]=es2015" }
        ]
    },

    watch: NODE_ENV === 'development',

    watchOptions: {
        aggregateTimeout: 100
    },

    devtool: NODE_ENV === 'development' ? 'eval' : null
};