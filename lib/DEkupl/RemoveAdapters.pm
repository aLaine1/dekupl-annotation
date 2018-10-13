package DEkupl::RemoveAdapters;
# ABSTRACT: Run Blast Aligner to remove adapters

use Moose;
use File::Temp;

with 'DEkupl::Base';

has 'nb_threads' => (
  is => 'rw',
  isa => 'Int',
  default => 1
);

has 'fasta' => (
  is => 'ro',
);

sub BUILD {
  my $self = shift;
  DEkupl::Utils::checkBlastnVersion();
  DEkupl::Utils::checkMakeblastdbVersion();
}

my $fasta_content =<<END;
>Illumina_Single_End_Apapter_1
ACACTCTTTCCCTACACGACGCTGTTCCATCT
>Illumina_Single_End_Apapter_2
CAAGCAGAAGACGGCATACGAGCTCTTCCGATCT
>Illumina_Single_End_PCR_Primer_1
AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Illumina_Single_End_PCR_Primer_2
CAAGCAGAAGACGGCATACGAGCTCTTCCGATCT
>Illumina_Single_End_Sequencing_Primer
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Illumina_Paired_End_Adapter_1
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Illumina_Paired_End_Adapter_2
CTCGGCATTCCTGCTGAACCGCTCTTCCGATCT
>Illumina_Paried_End_PCR_Primer_1
AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Illumina_Paired_End_PCR_Primer_2
CAAGCAGAAGACGGCATACGAGATCGGTCTCGGCATTCCTGCTGAACCGCTCTTCCGATCT
>Illumina_Paried_End_Sequencing_Primer_1
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Illumina_Paired_End_Sequencing_Primer_2
CGGTCTCGGCATTCCTACTGAACCGCTCTTCCGATCT
>Illumina_DpnII_expression_Adapter_1
ACAGGTTCAGAGTTCTACAGTCCGAC
>Illumina_DpnII_expression_Adapter_2
CAAGCAGAAGACGGCATACGA
>Illumina_DpnII_expression_PCR_Primer_1
CAAGCAGAAGACGGCATACGA
>Illumina_DpnII_expression_PCR_Primer_2
AATGATACGGCGACCACCGACAGGTTCAGAGTTCTACAGTCCGA
>Illumina_DpnII_expression_Sequencing_Primer
CGACAGGTTCAGAGTTCTACAGTCCGACGATC
>Illumina_NlaIII_expression_Adapter_1
ACAGGTTCAGAGTTCTACAGTCCGACATG
>Illumina_NlaIII_expression_Adapter_2
CAAGCAGAAGACGGCATACGA
>Illumina_NlaIII_expression_PCR_Primer_1
CAAGCAGAAGACGGCATACGA
>Illumina_NlaIII_expression_PCR_Primer_2
AATGATACGGCGACCACCGACAGGTTCAGAGTTCTACAGTCCGA
>Illumina_NlaIII_expression_Sequencing_Primer
CCGACAGGTTCAGAGTTCTACAGTCCGACATG
>Illumina_Small_RNA_Adapter_1
GTTCAGAGTTCTACAGTCCGACGATC
>Illumina_Small_RNA_Adapter_2
TCGTATGCCGTCTTCTGCTTGT
>Illumina_Small_RNA_RT_Primer
CAAGCAGAAGACGGCATACGA
>Illumina_Small_RNA_PCR_Primer_1
CAAGCAGAAGACGGCATACGA
>Illumina_Small_RNA_PCR_Primer_2
AATGATACGGCGACCACCGACAGGTTCAGAGTTCTACAGTCCGA
>Illumina_Small_RNA_Sequencing_Primer
CGACAGGTTCAGAGTTCTACAGTCCGACGATC
>Illumina_Multiplexing_Adapter_1
GATCGGAAGAGCACACGTCT
>Illumina_Multiplexing_Adapter_2
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Illumina_Multiplexing_PCR_Primer_1.01
AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Illumina_Multiplexing_PCR_Primer_2.01
GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT
>Illumina_Multiplexing_Read1_Sequencing_Primer
ACACTCTTTCCCTACACGACGCTCTTCCGATCT
>Illumina_Multiplexing_Index_Sequencing_Primer
GATCGGAAGAGCACACGTCTGAACTCCAGTCAC
>Illumina_Multiplexing_Read2_Sequencing_Primer
GTGACTGGAGTTCAGACGTGTGCTCTTCCGATCT
>Illumina_PCR_Primer_Index_1
CAAGCAGAAGACGGCATACGAGATCGTGATGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_2
CAAGCAGAAGACGGCATACGAGATACATCGGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_3
CAAGCAGAAGACGGCATACGAGATGCCTAAGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_4
CAAGCAGAAGACGGCATACGAGATTGGTCAGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_5
CAAGCAGAAGACGGCATACGAGATCACTGTGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_6
CAAGCAGAAGACGGCATACGAGATATTGGCGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_7
CAAGCAGAAGACGGCATACGAGATGATCTGGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_8
CAAGCAGAAGACGGCATACGAGATTCAAGTGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_9
CAAGCAGAAGACGGCATACGAGATCTGATCGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_10
CAAGCAGAAGACGGCATACGAGATAAGCTAGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_11
CAAGCAGAAGACGGCATACGAGATGTAGCCGTGACTGGAGTTC
>Illumina_PCR_Primer_Index_12
CAAGCAGAAGACGGCATACGAGATTACAAGGTGACTGGAGTTC
>Illumina_DpnII_Gex_Adapter_1
GATCGTCGGACTGTAGAACTCTGAAC
>Illumina_DpnII_Gex_Adapter_1.01
ACAGGTTCAGAGTTCTACAGTCCGAC
>Illumina_DpnII_Gex_Adapter_2
CAAGCAGAAGACGGCATACGA
>Illumina_DpnII_Gex_Adapter_2.01
TCGTATGCCGTCTTCTGCTTG
>Illumina_DpnII_Gex_PCR_Primer_1
CAAGCAGAAGACGGCATACGA
>Illumina_DpnII_Gex_PCR_Primer_2
AATGATACGGCGACCACCGACAGGTTCAGAGTTCTACAGTCCGA
>Illumina_DpnII_Gex_Sequencing_Primer
CGACAGGTTCAGAGTTCTACAGTCCGACGATC
>Illumina_NlaIII_Gex_Adapter_1.01
TCGGACTGTAGAACTCTGAAC
>Illumina_NlaIII_Gex_Adapter_1.02
ACAGGTTCAGAGTTCTACAGTCCGACATG
>Illumina_NlaIII_Gex_Adapter_2.01
CAAGCAGAAGACGGCATACGA
>Illumina_NlaIII_Gex_Adapter_2.02
TCGTATGCCGTCTTCTGCTTG
>Illumina_NlaIII_Gex_PCR_Primer_1
CAAGCAGAAGACGGCATACGA
>Illumina_NlaIII_Gex_PCR_Primer_2
AATGATACGGCGACCACCGACAGGTTCAGAGTTCTACAGTCCGA
>Illumina_NlaIII_Gex_Sequencing_Primer
CCGACAGGTTCAGAGTTCTACAGTCCGACATG
>Illumina_Small_RNA_RT_Primer
CAAGCAGAAGACGGCATACGA
>Illumina_5p_RNA_Adapter
GTTCAGAGTTCTACAGTCCGACGATC
>Illumina_RNA_Adapter1
TCGTATGCCGTCTTCTGCTTGT
>Illumina_Small_RNA_3p_Adapter_1
ATCTCGTATGCCGTCTTCTGCTTG
>Illumina_Small_RNA_PCR_Primer_1
CAAGCAGAAGACGGCATACGA
>Illumina_Small_RNA_PCR_Primer_2
AATGATACGGCGACCACCGACAGGTTCAGAGTTCTACAGTCCGA
>Illumina_Small_RNA_Sequencing_Primer
CGACAGGTTCAGAGTTCTACAGTCCGACGATC
>TruSeq_Universal_Adapter
AATGATACGGCGACCACCGAGATCTACACTCTTTCCCTACACGACGCTCTTCCGATCT
>TruSeq_Adapter,_Index_1
GATCGGAAGAGCACACGTCTGAACTCCAGTCACATCACGATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_2
GATCGGAAGAGCACACGTCTGAACTCCAGTCACCGATGTATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_3
GATCGGAAGAGCACACGTCTGAACTCCAGTCACTTAGGCATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_4
GATCGGAAGAGCACACGTCTGAACTCCAGTCACTGACCAATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_5
GATCGGAAGAGCACACGTCTGAACTCCAGTCACACAGTGATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_6
GATCGGAAGAGCACACGTCTGAACTCCAGTCACGCCAATATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_7
GATCGGAAGAGCACACGTCTGAACTCCAGTCACCAGATCATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_8
GATCGGAAGAGCACACGTCTGAACTCCAGTCACACTTGAATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_9
GATCGGAAGAGCACACGTCTGAACTCCAGTCACGATCAGATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_10
GATCGGAAGAGCACACGTCTGAACTCCAGTCACTAGCTTATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_11
GATCGGAAGAGCACACGTCTGAACTCCAGTCACGGCTACATCTCGTATGCCGTCTTCTGCTTG
>TruSeq_Adapter,_Index_12
GATCGGAAGAGCACACGTCTGAACTCCAGTCACCTTGTAATCTCGTATGCCGTCTTCTGCTTG
>Illumina_RNA_RT_Primer
GCCTTGGCACCCGAGAATTCCA
>Illumina_RNA_PCR_Primer
AATGATACGGCGACCACCGAGATCTACACGTTCAGAGTTCTACAGTCCGA
>RNA_PCR_Primer,_Index_1
CAAGCAGAAGACGGCATACGAGATCGTGATGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_2
CAAGCAGAAGACGGCATACGAGATACATCGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_3
CAAGCAGAAGACGGCATACGAGATGCCTAAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_4
CAAGCAGAAGACGGCATACGAGATTGGTCAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_5
CAAGCAGAAGACGGCATACGAGATCACTGTGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_6
CAAGCAGAAGACGGCATACGAGATATTGGCGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_7
CAAGCAGAAGACGGCATACGAGATGATCTGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_8
CAAGCAGAAGACGGCATACGAGATTCAAGTGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_9
CAAGCAGAAGACGGCATACGAGATCTGATCGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_10
CAAGCAGAAGACGGCATACGAGATAAGCTAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_11
CAAGCAGAAGACGGCATACGAGATGTAGCCGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_12
CAAGCAGAAGACGGCATACGAGATTACAAGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_13
CAAGCAGAAGACGGCATACGAGATTTGACTGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_14
CAAGCAGAAGACGGCATACGAGATGGAACTGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_15
CAAGCAGAAGACGGCATACGAGATTGACATGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_16
CAAGCAGAAGACGGCATACGAGATGGACGGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_17
CAAGCAGAAGACGGCATACGAGATCTCTACGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_18
CAAGCAGAAGACGGCATACGAGATGCGGACGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_19
CAAGCAGAAGACGGCATACGAGATTTTCACGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_20
CAAGCAGAAGACGGCATACGAGATGGCCACGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_21
CAAGCAGAAGACGGCATACGAGATCGAAACGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_22
CAAGCAGAAGACGGCATACGAGATCGTACGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_23
CAAGCAGAAGACGGCATACGAGATCCACTCGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_24
CAAGCAGAAGACGGCATACGAGATGCTACCGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_25
CAAGCAGAAGACGGCATACGAGATATCAGTGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_26
CAAGCAGAAGACGGCATACGAGATGCTCATGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_27
CAAGCAGAAGACGGCATACGAGATAGGAATGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_28
CAAGCAGAAGACGGCATACGAGATCTTTTGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_29
CAAGCAGAAGACGGCATACGAGATTAGTTGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_30
CAAGCAGAAGACGGCATACGAGATCCGGTGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_31
CAAGCAGAAGACGGCATACGAGATATCGTGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_32
CAAGCAGAAGACGGCATACGAGATTGAGTGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_33
CAAGCAGAAGACGGCATACGAGATCGCCTGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_34
CAAGCAGAAGACGGCATACGAGATGCCATGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_35
CAAGCAGAAGACGGCATACGAGATAAAATGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_36
CAAGCAGAAGACGGCATACGAGATTGTTGGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_37
CAAGCAGAAGACGGCATACGAGATATTCCGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_38
CAAGCAGAAGACGGCATACGAGATAGCTAGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_39
CAAGCAGAAGACGGCATACGAGATGTATAGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_40
CAAGCAGAAGACGGCATACGAGATTCTGAGGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_41
CAAGCAGAAGACGGCATACGAGATGTCGTCGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_42
CAAGCAGAAGACGGCATACGAGATCGATTAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_43
CAAGCAGAAGACGGCATACGAGATGCTGTAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_44
CAAGCAGAAGACGGCATACGAGATATTATAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_45
CAAGCAGAAGACGGCATACGAGATGAATGAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_46
CAAGCAGAAGACGGCATACGAGATTCGGGAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_47
CAAGCAGAAGACGGCATACGAGATCTTCGAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>RNA_PCR_Primer,_Index_48
CAAGCAGAAGACGGCATACGAGATTGCCGAGTGACTGGAGTTCCTTGGCACCCGAGAATTCCA
>ABI_Dynabead_EcoP_Oligo
CTGATCTAGAGGTACCGGATCCCAGCAGT
>ABI_Solid3_Adapter_A
CTGCCCCGGGTTCCTCATTCTCTCAGCAGCATG
>ABI_Solid3_Adapter_B
CCACTACGCCTCCGCTTTCCTCTCTATGGGCAGTCGGTGAT
>ABI_Solid3_5'_AMP_Primer
CCACTACGCCTCCGCTTTCCTCTCTATG
>ABI_Solid3_3'_AMP_Primer
CTGCCCCGGGTTCCTCATTCT
>ABI_Solid3_EF1_alpha_Sense_Primer
CATGTGTGTTGAGAGCTTC
>ABI_Solid3_EF1_alpha_Antisense_Primer
GAAAACCAAAGTGGTCCAC
>ABI_Solid3_GAPDH_Forward_Primer
TTAGCACCCCTGGCCAAGG
>ABI_Solid3_GAPDH_Reverse_Primer
CTTACTCCTTGGAGGCCATG
END

sub _getAdaptersFasta {
  my $self = shift;
  my $adapters_fasta = File::Temp->new(UNLINK => 1, SUFFIX => '.fa');
  $self->verboseLog("Generate FASTA with adapters in $adapters_fasta");
  print $adapters_fasta $fasta_content;
  close($adapters_fasta);
  return $adapters_fasta;
}

sub _createBlastIndex {
  my $self = shift;
  my $fasta;
  # Use default adapters of fasta file supplied by the user
  if(defined $self->fasta) {
    $fasta = $self->fasta;
  } else {
    $fasta = $self->_getAdaptersFasta();
  }
  my $blast_index_basename = File::Temp->new(UNLINK => 1, SUFFIX => '');
  my $logs = File::Temp->new(UNLINK => 0, SUFFIX => '.log');
  $self->verboseLog("Create BLAST Index, basename $blast_index_basename");
  my $command = join(" ",
    "makeblastdb",
    "-in $fasta",
    "-dbtype nucl",
    "-out $blast_index_basename",
    "2> $logs",
    ">> $logs",
  );
  system($command) == 0 or die("Blast db creation failed, see logs in $logs");
  unlink $logs;
  return $blast_index_basename;
}

sub removeAdapterContigs {
  my $self = shift;
  my $contigs_db = shift;

  # Create blast index
  my $blast_db = $self->_createBlastIndex();

  # Create temporary files
  my $contigs_fasta = File::Temp->new(UNLINK => 0, SUFFIX => '.fa');
  my $logs          = File::Temp->new(UNLINK => 0, SUFFIX => '.log');
  my $results       = File::Temp->new(UNLINK => 0, SUFFIX => '.txt');

  # Generate FASTA file with contigs from contigs db
  $contigs_db->generateFasta($contigs_fasta);
  
  # Run Blastn
  my $command = join(" ",
    "blastn",
    "-query $contigs_fasta",
    "-db $blast_db",
    "-evalue 1e-4",
    "-word_size 11",
    "-max_target_seqs 500",
    "-task blastn",
    '-outfmt "6 qseqid sseqid pident length mismatch gaps qstart qend sstart send evalue bitscore qlen sstrand"',
    "-out $results",
    "-num_threads " . $self->nb_threads,
    "2> $logs"
  );
  system($command) == 0 or die("Blast of contigs against adapters failed, see logs in $logs");
  unlink $logs;
  unlink $contigs_fasta;

  # Selecting contigs matching adapters from blastn results
  my %aligned_contigs;
  {
    open(my $fh, '<', $results) or die("Cannot open $results");
    while(<$fh>) {
      chomp;
      # ACACTCTTTCCCTACACGACGCTGTTCCATCT        Illumina_Single_End_Apapter_1   100.000 32      0       0       1       32      1       32      1.77e-13        59.0    32      plus
      my ($contig_id, $adapteur_id, $p_identity) = split "\t", $_;
      $aligned_contigs{$contig_id}++;
    }
  }
  unlink $results;
  
  # Delete selected contigs
  foreach my $contig_id (keys %aligned_contigs) {
    $contigs_db->deleteContig($contig_id);
  }
  $self->log("Remove ". (scalar keys %aligned_contigs) . " contigs matching adapters");
}

no Moose;
__PACKAGE__->meta->make_immutable;