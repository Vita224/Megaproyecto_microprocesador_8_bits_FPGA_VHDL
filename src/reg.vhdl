library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity reg is 
    port(
        clock: in STD_LOGIC;
        reset: in STD_LOGIC;
        out_en: in STD_LOGIC;
        load: in STD_LOGIC;
        input: in STD_LOGIC_VECTOR(7 downto 0);
        output: out STD_LOGIC_VECTOR(7 downto 0);
        output_alu: out STD_LOGIC_VECTOR(7 downto 0)
    );
end entity;

architecture behave of reg is
    signal stored_value: STD_LOGIC_VECTOR(7 downto 0) := (others => '0');
begin
    process(clock, reset)
    begin
        if reset = '1' then
            stored_value <= (others => '0');
        elsif rising_edge(clock) then
            if load = '1' then
                stored_value <= input;
            end if;    
        end if;
    end process;

    -- Salidas siempre conducidas. El CPU decide via señales de control cual usar.
    output <= stored_value;
    output_alu <= stored_value;
end behave;
