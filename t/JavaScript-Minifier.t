# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl JavaScript-Minifier.t'

#########################

use Test::More tests => 17;
BEGIN { use_ok('JavaScript::Minifier', qw(minify)) };

#########################

sub filesMatch {
  my $file1 = shift;
  my $file2 = shift;
  my $a;
  my $b;

  while (1) {
    $a = getc($file1);
    $b = getc($file2);

    if (!defined($a) && !defined($b)) { # both files end at same place
      return 1;
    }
    elsif (!defined($b) || # file2 ends first
           !defined($a) || # file1 ends first
           $a ne $b) {     # a and b not the same
      return 0;
    }
  }
}

sub minTest {
  my $filename = shift;
  
  open(INFILE, 't/scripts/' . $filename . '.js') or die("couldn't open file");
  open(GOTFILE, '>t/scripts/' . $filename . '-got.js') or die("couldn't open file");
    minify(input => *INFILE, outfile => *GOTFILE);
  close(INFILE);
  close(GOTFILE);

  open(EXPECTEDFILE, 't/scripts/' . $filename . '-expected.js') or die("couldn't open file");
  open(GOTFILE, 't/scripts/' . $filename . '-got.js') or die("couldn't open file");
    ok(filesMatch(GOTFILE, EXPECTEDFILE));
  close(EXPECTEDFILE);
  close(GOTFILE);
}

BEGIN {
  
  minTest('s2', 'testing s2');    # missing semi-colons
  minTest('s3', 'testing s3');    # //@
  minTest('s4', 'testing s4');    # /*@*/
  minTest('s5', 'testing s5');    # //
  minTest('s6', 'testing s6');    # /**/
  minTest('s7', 'testing s7');    # blocks of comments
  minTest('s8', 'testing s8');    # + + - -
  minTest('s9', 'testing s9');    # alphanum
  minTest('s10', 'testing s10');  # }])
  minTest('s11', 'testing s11');  # string and regexp literals
  minTest('s12', 'testing s12');  # other characters
  minTest('s13', 'testing s13');  # comment at start
  minTest('s14', 'testing s14');  # slash following square bracket is division not RegExp

  is(minify(input => 'var x = 2;'), 'var x=2;', 'string literal input and ouput');
  is(minify(input => "var x = 2;\n;;;alert('hi');\nvar x = 2;", stripDebug => 1), 'var x=2;var x=2;', 'scriptDebug option');
  is(minify(input => 'var x = 2;', copyright => "BSD"), '/* BSD */var x=2;', 'copyright option');

}