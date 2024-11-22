# Post-route optimization script

proc optimize_critical_paths {} {
    # Get worst timing paths
    set worst_paths [get_timing_paths -max_paths 10 -nworst 1 -setup]
    
    foreach path $worst_paths {
        # Get slack and endpoint
        set slack [get_property SLACK $path]
        set endpoint [get_property ENDPOINT $path]
        
        if {$slack < 0} {
            # Try physical optimization
            puts "Optimizing path to $endpoint (slack: $slack)"
            phys_opt_design -directive AggressiveFanoutOpt
            
            # Check if improved
            set new_slack [get_property SLACK [get_timing_paths -to $endpoint -max_paths 1]]
            puts "New slack: $new_slack"
        }
    }
}

proc check_safety_timing {} {
    # Check timing for safety-critical paths
    set safety_paths [get_timing_paths -through [get_cells -hierarchical *safety*] -max_paths 100]
    
    foreach path $safety_paths {
        set slack [get_property SLACK $path]
        if {$slack < 1.0} {  # Extra margin for safety paths
            puts "WARNING: Safety path has insufficient margin (slack: $slack)"
            report_timing -of_objects $path -file reports/safety_timing_violations.rpt -append
        }
    }
}

proc generate_reports {} {
    # Generate detailed timing reports
    report_timing_summary -delay_type min_max -report_unconstrained -check_timing_verbose \
        -max_paths 100 -input_pins -file reports/post_route_timing.rpt
    
    # Generate power analysis
    report_power -file reports/post_route_power.rpt
    
    # Generate utilization report
    report_utilization -hierarchical -file reports/post_route_utilization.rpt
    
    # Generate DRC report
    report_drc -file reports/post_route_drc.rpt
}

# Run optimizations
optimize_critical_paths
check_safety_timing
generate_reports