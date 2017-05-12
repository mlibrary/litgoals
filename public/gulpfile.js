'use strict';

var gulp = require('gulp');
var sass = require('gulp-sass');

// Compile sass into CSS
gulp.task('sass', function() {
  return gulp.src("./stylesheets/main.scss")
    .pipe(sass().on('error', sass.logError))
    .pipe(gulp.dest("./assets/stylesheets"));
});

gulp.task('sass:watch', function () {
  gulp.watch('./stylesheets/*.scss', ['sass']);
  gulp.watch('./stylesheets/**/*.scss', ['sass']);
});

gulp.task('default', ['sass:watch']);
