##! Enable log output to TCP.

module LogTCP;

export {
    ## Optionally ignore any specified :zeek:type:`Log::ID` from being sent to
    ## TCP.
    const excluded_log_ids: set[Log::ID] &redef;

    ## If you want to explicitly only send certain :zeek:type:`Log::ID`
    ## streams, add them to this set.  If the set remains empty, all will
    ## be sent.  The :zeek:id:`LogTCP::excluded_log_ids` option
    ## will remain in effect as well.
    const send_logs: set[Log::ID] &redef;
}

event zeek_init() &priority=-5 {
    if (host == "")
        return;

    for (stream_id in Log::active_streams) {
        if (stream_id in excluded_log_ids || (|send_logs| > 0 && stream_id !in send_logs))
            next;

        local filter: Log::Filter = [$name = "default-tcp", $writer = Log::WRITER_TCP, $interv = 0 sec];
        Log::add_filter(stream_id, filter);
    }
}
