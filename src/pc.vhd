library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pc is 
    port(
        clock: in STD_LOGIC; -- Se�al de reloj
        reset: in STD_LOGIC; -- Se�al de reinicio
        en: in STD_LOGIC; -- Se�al de habilitaci�n del contador
        oe: in STD_LOGIC; -- Se�al de habilitaci�n de la salida
        ld: in STD_LOGIC; -- Se�al de carga
        input: in STD_LOGIC_VECTOR(3 downto 0); -- Entrada de datos para carga
        output: out STD_LOGIC_VECTOR(3 downto 0) -- Salida del contador
    );
end entity;

-- Arquitectura -- 
architecture behave of pc is
    signal count: STD_LOGIC_VECTOR(3 downto 0) := "0000"; -- Declara una se�al count de 4 bits que act�a como el contador principal.
	
begin
    process(clock, reset)
    begin
        if reset = '1' then
            count <= "0000";
        elsif rising_edge(clock) then
            if ld = '1' then
                count <= input;
            elsif en = '1' then
                count <= count + 1;
            end if;
        end if;
    end process;

    output <= count when oe = '1' else "ZZZZ";

end behave;
