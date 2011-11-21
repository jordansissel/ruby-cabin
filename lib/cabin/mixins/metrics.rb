require "cabin/namespace"

# What kind of metrics do we want?
# Per-call/transaction/request metrics like:
#   - hit (count++ type metrics)
#   - latencies/timings
#
# Per app or generally long-lifetime metrics like:
#   - "uptime"
#   - cpu usage
#   - memory usage
#   - count of active/in-flight actions/requests/calls/transactions
#   - peer metrics (number of cluster members, etc)
module Cabin::Mixins::Metrics

end # module Cabin::Mixins::Metrics
