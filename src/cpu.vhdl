library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity cpu is 
    port(
        clock : in  STD_LOGIC;
        reset : in  STD_LOGIC;
        RxD   : in  STD_LOGIC;
        op    : out STD_LOGIC_VECTOR(7 downto 0)
    );
end entity;

architecture behave of cpu is

    --------------------------------------------------------------------------
    -- COMPONENTES
    --------------------------------------------------------------------------
    component pc is
        port(
            clock  : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            en     : in  STD_LOGIC;
            oe     : in  STD_LOGIC;
            ld     : in  STD_LOGIC;
            data_in  : in  STD_LOGIC_VECTOR(3 downto 0);
            data_out : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component reg is
        port(
            clock      : in  STD_LOGIC;
            reset      : in  STD_LOGIC;
            out_en     : in  STD_LOGIC;
            load       : in  STD_LOGIC;
            data_in      : in  STD_LOGIC_VECTOR(7 downto 0);
            data_out     : out STD_LOGIC_VECTOR(7 downto 0);
            alu_out : out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component mem is
        Port (
            reset         : in  STD_LOGIC;
            clock         : in  STD_LOGIC;
            load          : in  STD_LOGIC;
            oe            : in  STD_LOGIC;
            addr_in       : in  STD_LOGIC_VECTOR(3 downto 0);
            data_in       : in  STD_LOGIC_VECTOR(7 downto 0);
            data_out      : out STD_LOGIC_VECTOR(7 downto 0);
            RxD           : in  STD_LOGIC;
            slow_mode     : out STD_LOGIC;
            program_ready : out STD_LOGIC
        );
    end component;

    component mar is
        port(
            clock  : in  STD_LOGIC;
            reset  : in  STD_LOGIC;
            load   : in  STD_LOGIC;
            data_in  : in  STD_LOGIC_VECTOR(3 downto 0);
            data_out : out STD_LOGIC_VECTOR(3 downto 0)
        );
    end component;

    component alu is
        port(
            en        : in  STD_LOGIC;
            op        : in  STD_LOGIC;
            reg_a_in  : in  STD_LOGIC_VECTOR(7 downto 0);
            reg_b_in  : in  STD_LOGIC_VECTOR(7 downto 0);
            carry_out : out STD_LOGIC;
            zero_flag : out STD_LOGIC;
            result_out: out STD_LOGIC_VECTOR(7 downto 0)
        );
    end component;

    component control_unit is
        port(
            clock : in  STD_LOGIC;
            reset : in  STD_LOGIC;
            instr : in  STD_LOGIC_VECTOR(3 downto 0);
            do    : out STD_LOGIC_VECTOR(16 downto 0)
        );
    end component;

    --------------------------------------------------------------------------
    -- SEÑALES INTERNAS
    --------------------------------------------------------------------------
    signal main_bus              : STD_LOGIC_VECTOR(7 downto 0);
    signal cu_out_sig            : STD_LOGIC_VECTOR(16 downto 0);
    signal instr_out_sig         : STD_LOGIC_VECTOR(7 downto 0);
    signal instr_out             : STD_LOGIC_VECTOR(3 downto 0);

    signal pc_en_sig, pc_oe_sig, pc_ld_sig : STD_LOGIC;
    signal mar_ld_sig                      : STD_LOGIC;
    signal mem_ld_sig, mem_oe_sig          : STD_LOGIC;
    signal reg_a_ld_sig, reg_a_oe_sig      : STD_LOGIC;
    signal reg_b_ld_sig, reg_b_oe_sig      : STD_LOGIC;
    signal reg_op_ld_sig, reg_op_oe_sig    : STD_LOGIC;
    signal instr_ld_sig, instr_oe_sig      : STD_LOGIC;
    signal alu_en_sig, alu_op_sig          : STD_LOGIC;

    signal mar_mem_sig    : STD_LOGIC_VECTOR(3 downto 0);
    signal mem_in_bus     : STD_LOGIC_VECTOR(7 downto 0);
    signal mem_data_out   : STD_LOGIC_VECTOR(7 downto 0);
    signal reg_a_out      : STD_LOGIC_VECTOR(7 downto 0);
    signal reg_b_out      : STD_LOGIC_VECTOR(7 downto 0);
    signal reg_a_alu      : STD_LOGIC_VECTOR(7 downto 0);
    signal reg_b_alu      : STD_LOGIC_VECTOR(7 downto 0);
    signal pc_out         : STD_LOGIC_VECTOR(3 downto 0);
    signal mem_addr       : STD_LOGIC_VECTOR(3 downto 0);

    signal alu_out        : STD_LOGIC_VECTOR(7 downto 0);

    -- Señales para modo lento y programa cargado
    signal slow_mode_sig     : STD_LOGIC;
    signal program_ready_sig : STD_LOGIC;

    -- Señal intermedia para habilitar PC
    signal pc_enable : STD_LOGIC;

    -- Divisor de reloj
    constant SLOW_WIDTH : natural := 22;
    constant SLOW_MAX   : unsigned(SLOW_WIDTH-1 downto 0) := to_unsigned(2999999, SLOW_WIDTH);
    signal slow_counter : unsigned(SLOW_WIDTH-1 downto 0);
    signal slow_clk     : STD_LOGIC;
    signal cpu_clk      : STD_LOGIC;
    signal cu_clk       : STD_LOGIC;
    
    signal dummy_instr_out : STD_LOGIC_VECTOR(7 downto 0);
    signal dummy_op_out    : STD_LOGIC_VECTOR(7 downto 0);
    signal dummy_carry : STD_LOGIC;
    signal dummy_zero  : STD_LOGIC;

begin

    --------------------------------------------------------------------------
    -- Divisor de reloj
    --------------------------------------------------------------------------
    process(clock, reset)
    begin
        if reset = '1' then
            slow_counter <= (others => '0');
            slow_clk     <= '0';
        elsif rising_edge(clock) then
            if slow_mode_sig = '1' then
                if slow_counter = SLOW_MAX then
                    slow_counter <= (others => '0');
                    slow_clk     <= not slow_clk;
                else
                    slow_counter <= slow_counter + 1;
                end if;
            else
                slow_clk <= clock;
            end if;
        end if;
    end process;

    cpu_clk   <= slow_clk when slow_mode_sig = '1' else clock;
    cu_clk    <= not cpu_clk;
    pc_enable <= pc_en_sig and program_ready_sig;

    --------------------------------------------------------------------------
    -- INSTANCIAS
    --------------------------------------------------------------------------
    pc_instr: pc port map(
        clock  => cpu_clk,
        reset  => reset,
        en     => pc_enable,
        oe     => pc_oe_sig,
        ld     => pc_ld_sig,
        data_in  => main_bus(3 downto 0),
        data_out => pc_out
    );

    cu_instr: control_unit port map(
        clock => cu_clk,
        reset => reset,
        instr => instr_out,
        do    => cu_out_sig
    );

    mar_instr: mar port map(
        clock  => cpu_clk,
        reset  => reset,
        load   => mar_ld_sig,
        data_in  => main_bus(3 downto 0),
        data_out => mar_mem_sig
    );

    mem_instr: mem port map(
        reset         => reset,
        clock         => clock,
        load          => mem_ld_sig,
        oe            => mem_oe_sig,
        addr_in       => mem_addr,
        data_in       => mem_in_bus,
        data_out      => mem_data_out,
        RxD           => RxD,
        slow_mode     => slow_mode_sig,
        program_ready => program_ready_sig
    );

    instr_reg_instr: reg port map(
        clock      => cpu_clk,
        reset      => reset,
        out_en     => instr_oe_sig,
        load       => instr_ld_sig,
        data_in      => main_bus,
        data_out     => dummy_instr_out,
        alu_out => instr_out_sig
    );

    reg_A_instr: reg port map(
        clock      => cpu_clk,
        reset      => reset,
        out_en     => reg_a_oe_sig,
        load       => reg_a_ld_sig,
        data_in      => main_bus,
        data_out     => reg_a_out,
        alu_out => reg_a_alu
    );

    reg_B_instr: reg port map(
        clock      => cpu_clk,
        reset      => reset,
        out_en     => reg_b_oe_sig,
        load       => reg_b_ld_sig,
        data_in      => main_bus,
        data_out     => reg_b_out,
        alu_out => reg_b_alu
    );

    reg_op_instr: reg port map(
        clock      => cpu_clk,
        reset      => reset,
        out_en     => reg_op_oe_sig,
        load       => reg_op_ld_sig,
        data_in      => main_bus,
        data_out     => dummy_op_out,
        alu_out => op
    );

    alu_instr: alu port map(
        en         => alu_en_sig,
        op         => alu_op_sig,
        reg_a_in   => reg_a_alu,
        reg_b_in   => reg_b_alu,
        carry_out  => dummy_carry,
        zero_flag  => dummy_zero,
        result_out => alu_out
    );

    --------------------------------------------------------------------------
    -- Conexiones internas
    --------------------------------------------------------------------------
    mem_addr   <= mar_mem_sig;
    mem_in_bus <= main_bus;
    instr_out  <= instr_out_sig(7 downto 4);

    -- Multiplexor del bus principal
    bus_arbiter_proc: process(alu_en_sig, mem_oe_sig, reg_a_oe_sig, reg_b_oe_sig, pc_oe_sig, instr_oe_sig,
                              alu_out, mem_data_out, reg_a_alu, reg_b_alu, pc_out, instr_out_sig)
    begin
        if alu_en_sig = '1' then
            main_bus <= alu_out;
        elsif mem_oe_sig = '1' then
            main_bus <= mem_data_out;
        elsif reg_a_oe_sig = '1' then
            main_bus <= reg_a_alu;
        elsif reg_b_oe_sig = '1' then
            main_bus <= reg_b_alu;
        elsif pc_oe_sig = '1' then
            main_bus <= "0000" & pc_out;
        elsif instr_oe_sig = '1' then
            main_bus <= "0000" & instr_out_sig(3 downto 0);
        else
            main_bus <= (others => '0');
        end if;
    end process;

    --------------------------------------------------------------------------
    -- Señales de control
    --------------------------------------------------------------------------
    pc_en_sig     <= cu_out_sig(11);
    pc_ld_sig     <= cu_out_sig(10);
    pc_oe_sig     <= cu_out_sig(9);
    mar_ld_sig    <= cu_out_sig(8);
    mem_ld_sig    <= cu_out_sig(7);
    mem_oe_sig    <= cu_out_sig(6);
    reg_a_ld_sig  <= cu_out_sig(5);
    reg_a_oe_sig  <= cu_out_sig(4);
    reg_b_ld_sig  <= cu_out_sig(3);
    reg_b_oe_sig  <= cu_out_sig(2);
    instr_ld_sig  <= cu_out_sig(1);
    instr_oe_sig  <= cu_out_sig(0);
    alu_en_sig    <= cu_out_sig(12);
    alu_op_sig    <= cu_out_sig(13);
    reg_op_ld_sig <= cu_out_sig(15);
    reg_op_oe_sig <= cu_out_sig(14);

end behave;
