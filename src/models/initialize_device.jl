function initialize_device!(
    residuals,
    device_initial_guess,
    voltage_r,
    voltage_i,
    device::DynG,
    sys::PSY.System,
) where {DynG <: PSY.DynamicGenerator}
    #Obtain local device states
    n_states = PSY.get_n_states(device)
    #Obtain references
    sys_Sbase = PSY.get_basepower(sys)
    sys_f0 = PSY.get_frequency(sys)
    sys_ω = get_ω_sys(sys)

    #Update Voltage data
    get_inner_vars(device)[VR_gen_var] = voltage_r
    get_inner_vars(device)[VI_gen_var] = voltage_i

    #Solve Machine
    mdl_machine_ode!(
        device_initial_guess,
        residuals,
        [0.0],
        [0.0],
        sys_Sbase,
        sys_f0,
        device,
    )

    #Obtain ODEs for PSY.Shaft
    mdl_shaft_ode!(device_initial_guess, residuals, sys_f0, sys_ω, device)

    #Obtain ODEs for AVR
    mdl_avr_ode!(device_initial_guess, residuals, device)

    #Obtain ODEs for AVR
    mdl_pss_ode!(device_initial_guess, residuals, sys_ω, device)

    #Obtain ODEs and Mechanical Power for Turbine Governor
    mdl_tg_ode!(device_initial_guess, residuals, device)

    return device_initial_guess
end
