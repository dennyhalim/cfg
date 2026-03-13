#!/usr/bin/perl
#http://digitalpbk.com/perl/perl-script-remove-directory-and-contents-recursively

#deldir("test"); # or deldir($ARGV[0]) to make it commandline
deldir($ARGV[0])

sub deldir {
  my $dirtodel = pop;
  my $sep = '/';
  opendir(DIR, $dirtodel);
  my @files = readdir(DIR);
  closedir(DIR);

  @files = grep { !/^\.{1,2}/ } @files;
  @files = map { $_ = "$dirtodel$sep$_"} @files;
  @files = map { (-d $_)?deldir($_):unlink($_) } @files;
  
  rmdir($dirtodel);
}
