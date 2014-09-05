package Dancer2::Session::Redis::Serialization::Sereal;
use strictures 1;
# ABSTRACT: Dancer2::Session::Redis serialization broker for Sereal.
# COPYRIGHT

BEGIN {
  our $VERSION = '0.001';  # fixed version - NOT handled via DZP::OurPkgVersion.
}

use Dancer2::Core::Types qw( Bool InstanceOf );
use Moo;
use Sereal::Decoder qw( looks_like_sereal );
use Sereal::Encoder qw( SRL_UNCOMPRESSED SRL_SNAPPY );

with 'Dancer2::Session::Redis::SerializationRole';

=head1 SYNOPSIS

In your I<config.yml>:

    engines:
      session:
        Redis:
          # ...
          # Use serialization for storing values other than simple scalars with Redis:
          redis_serialization:
            # Use Sereal as serialization module:
            module: "Dancer2::Session::Redis::Serialization::Sereal"
            # Serialization module configuration:
            # (optional) Enable Google Snappy compression (default):
            snappy: 1

=cut

############################################################################

has snappy => (
  is      => 'ro',
  isa     => Bool,
  default => 1,
);

has _decoder => (
  is      => 'lazy',
  isa     => InstanceOf ['Sereal::Decoder'],
  builder => sub { Sereal::Decoder->new },
);

has _encoder => (
  is      => 'lazy',
  isa     => InstanceOf ['Sereal::Encoder'],
  builder => sub {
    my ($self) = @_;
    my $snappy = $self->snappy ? SRL_SNAPPY : SRL_UNCOMPRESSED;
    return Sereal::Encoder->new( {
      compress           => $snappy,  # use Google Snappy compression algorithm if wanted.
      compress_threshold => 1024,     # compress when content is 1 kbyte or bigger.
      croak_on_bless     => 0,        # do not croak on blessed objects.
      undef_unknown      => 0,        # do not undef unknown objects.
      stringify_unknown  => 0,        # do not stringify unknown objects.
      warn_unknown       => 1,        # carp on unknown objects.
      sort_keys          => 0,        # do not sort keys. we do not care abount sorting but performance.
    } );
  },
);

############################################################################

sub decode {
  my ( $self, $serialized_object ) = @_;
  # deserealize stuff only if Sereal thinks it can do it.
  return $serialized_object unless looks_like_sereal $serialized_object;
  return $self->_decoder->decode($serialized_object);
}

=method decode

Deserialize a serialized object. Returns the (not really) serealized object without doing
anything to it if Sereal thinks it is not serealized.

=cut

sub encode {
  my ( $self, $raw_object ) = @_;
  return $raw_object if defined $raw_object && !ref $raw_object;  # do not serialize simple scalars (strings).
  return $self->_encoder->encode($raw_object);
}

=method encode

Serialize a raw object if it is a reference or undef.

=cut

############################################################################

=head1 DESCRIPTION

This module is a serialization broker for Dancer2::Session::Redis. It will
provide Dancer2::Session::Redis the ability to (de)serialize Redis values with
Sereal.

=head1 SEE ALSO

=over

=item L<Dancer2::Session::Redis>

=item L<Sereal>

=back

=cut

1;
