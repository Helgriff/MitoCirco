#!/usr/bin/perl
use LWP::UserAgent;
use HTTP::Request::Common;

my $userAgent = LWP::UserAgent->new(timeout => 1800); #a half-hour

my($path1, $file, $type)=@ARGV;

my $outfile2 = $path1."/".$file;

#fileType can be sequences or snvlist
my $request = POST 'http://mitomaster.mitomap.org/cgi-bin/websrvc.cgi',
    Content_Type => 'multipart/form-data',
    Content => [ file => [$outfile2], fileType => $type, output => 'detail'];

my $response = $userAgent->request($request);
print $response->error_as_HTML . "
" if $response->is_error;

if ($response->is_success) {
     print $response->decoded_content;
} else {
     die $response->status_line;
}
