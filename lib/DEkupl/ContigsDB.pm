package DEkupl::ContigsDB;
# ABSTRACT: Store informations for contigs

use Moose;
use JSON::XS;

use DEkupl::Utils;

has 'db_folder' => (
  is => 'ro',
  isa => 'Str',
  required => 1,
);

sub saveContig {
  my $self = shift;
  my $contig = shift;
  my $tag = $self->_getTag($contig);
  my $file = $self->_getContigFile($tag);
  my $json = encode_json $contig;
  DEkupl::Utils::saveToFile($file, $json);
}

sub loadContig {
  my $self = shift;
  my $tag = shift;
  my $file = $self->_getContigFile($tag);
  my $contig;
  if(-e $file) {
    my $json = DEkupl::Utils::slurpFile($file);
    $contig = decode_json $json;
  }
  return $contig;
}

sub deleteContig {
  my $self = shift;
  my $tag = shift;
  my $file = $self->_getContigFile($tag);
  my $contig;
  if(-e $file) {
    unlink $file;
  }
}

sub contigsIterator {
  my $self = shift;
  opendir(DIR, $self->db_folder) or die $!;
  #my $tag = readdir(DIR);
  my $tag;

  return sub {
  
    while($tag = readdir(DIR)) {
      #print STDERR "$tag\n";
      last if $tag !~ /^\./;
    }
    
    if($tag) {
      return $self->loadContig($tag);
    } else {
      return;
    }
  }
}

sub generateFasta {
  my $self = shift;
  my $fasta_file = shift;
  my $fh = DEkupl::Utils::getWritingFileHandle($fasta_file);
  my $contigs_it = $self->contigsIterator;
  while(my $contig = $contigs_it->()) {
    print $fh ">".$contig->{tag}."\n".$contig->{contig},"\n";
  }
  close($fh);
}

sub _getTag {
  my $self = shift;
  my $contig = shift;
  my $tag = $contig->{tag};
  die("Missing tag entry in contig") unless defined $tag;
  return $tag;
}

sub _getContigFile {
  my $self = shift;
  my $tag = shift;
  #return $self->db_folder . "/" . $tag . ".gz";
  return $self->db_folder . "/" . $tag;
}

no Moose;
__PACKAGE__->meta->make_immutable;