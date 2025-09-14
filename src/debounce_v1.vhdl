library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity debounce is
    generic(
        counter_size: INTEGER := 19  -- ajustable
    );
    port(
        clock: in STD_LOGIC;
        button: in STD_LOGIC;
        result: out STD_LOGIC
    );
end entity;

architecture logic of debounce is
    signal flipflops: STD_LOGIC_VECTOR(1 downto 0) := (others => '0');
    signal counter_set: STD_LOGIC;
    signal counter_out: unsigned(counter_size downto 0) := (others => '0');
begin
    counter_set <= flipflops(0) xor flipflops(1);

    process(clock)
    begin
        if rising_edge(clock) then
            flipflops(0) <= button;
            flipflops(1) <= flipflops(0);

            if (counter_set = '1') then 
                -- hubo cambio: reinicia contador
                counter_out <= (others => '0');
            elsif (counter_out(counter_size) = '0') then 
                -- sigue contando hasta que el MSB sea '1'
                counter_out <= counter_out + 1;
            else 
                -- cuando el contador llegó al tiempo requerido, actualiza la salida limpia
                result <= flipflops(1);
            end if;    
        end if;
    end process;
end logic;
