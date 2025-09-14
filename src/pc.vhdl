library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity pc is 
    port(
        clock: in STD_LOGIC;
        reset: in STD_LOGIC;
        en: in STD_LOGIC;
        oe: in STD_LOGIC;
        ld: in STD_LOGIC;
        input: in STD_LOGIC_VECTOR(3 downto 0);
        output: out STD_LOGIC_VECTOR(3 downto 0)
    );
end entity;

architecture behave of pc is
    signal count: unsigned(3 downto 0) := "0000";
begin
    process(clock, reset)
    begin
        if reset = '1' then
            count <= (others => '0');
        elsif rising_edge(clock) then
            if ld = '1' then
                count <= unsigned(input);
            elsif en = '1' then
                count <= count + 1;
            end if;
        end if;
    end process;

    output <= std_logic_vector(count) when oe = '1' else "ZZZZ";
end behave;
