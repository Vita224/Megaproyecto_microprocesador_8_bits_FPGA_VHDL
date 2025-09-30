library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity mar is 
    port(
        clock: in STD_LOGIC;
        reset: in STD_LOGIC;
        load: in STD_LOGIC;
        data_in: in STD_LOGIC_VECTOR(3 downto 0);
        data_out: out STD_LOGIC_VECTOR(3 downto 0)
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
                stored_value <= data_in;
            end if;    
        end if;
    end process;

    data_out <= stored_value;
end behave;
