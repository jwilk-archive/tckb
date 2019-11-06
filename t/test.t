#!/usr/bin/env perl

# Copyright © 2019 Jakub Wilk <jwilk@jwilk.net>
# SPDX-License-Identifier: MIT

no lib '.';  # CVE-2016-1238

use strict;
use warnings;

use File::Temp ();
use FindBin ();
use Test::More tests => 1;

use IPC::System::Simple qw(capture);

my $target = $ENV{TCKB_TEST_TARGET} // "$FindBin::Bin/../tckb";

my $tmpdir = File::Temp->newdir(TEMPLATE => 'tckb.test.XXXXXX', TMPDIR => 1);

sub run_tmux
{
    my @args = @_;
    return capture(qw(tmux -f /dev/null -S), "$tmpdir/tmux.socket", @args);
}

my $tmux_version = run_tmux('-V');
diag($tmux_version);
run_tmux(qw(
    start-server ;
    set-option -g remain-on-exit ;
    new-session -x 80 -y 24 -d), $target
);
sleep(1);
my $out = run_tmux('capture-pane', '-p');
run_tmux('kill-session');
like($out, qr/\A((▒)+\n)+Pane is dead\b/s, 'screen capture');
diag($out);

# vim:ts=4 sts=4 sw=4 et
