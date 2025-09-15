library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mar is 
    port(
        clock: in STD_LOGIC;
        reset: in STD_LOGIC;
        load: in STD_LOGIC;
        input: in STD_LOGIC_VECTOR(3 downto 0);
        output: out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity;

architecture behave of mar is
    signal stored_value: STD_LOGIC_VECTOR(3 downto 0) := (others => '0');
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

    output <= stored_value;
end behave;
