// Include gulp
const gulp 	= require( 'gulp' );
const babel = require( 'gulp-babel' );
const shell = require( 'gulp-shell' );

// Compile Source
gulp.task( 'compile', () => {
	return gulp.src( 'src/**/*.js' )
		.pipe( 
			babel( 
				{
					presets : [ 'es2015' ]
				} 
			)
		)
		.pipe( gulp.dest( 'dist' ) );
} );

// Run Tests
gulp.task( 
	'tests',  
	shell.task( [
		'npm run-script test'
	] )
);

// Watcher
gulp.task( 'watch', () => {
	// Watch .js files
	gulp.watch( 'src/**/*.js', [ 'compile' ] );
} );

// Default task is to compile and watch
gulp.task( 'default', [ 'compile', 'tests', 'watch' ] );