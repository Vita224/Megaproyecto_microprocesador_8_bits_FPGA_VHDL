library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port(
        en: in STD_LOGIC; -- Habilita la salida de la ALU
        op: in STD_LOGIC; -- Operación a realizar (0 para suma, 1 para resta)
        reg_a_in: in STD_LOGIC_VECTOR(7 downto 0); -- Operando A
        reg_b_in: in STD_LOGIC_VECTOR(7 downto 0); -- Operando B
        carry_out: out STD_LOGIC;
        zero_flag: out STD_LOGIC;
        result_out: out STD_LOGIC_VECTOR(7 downto 0)
    );
end entity;

architecture behave of alu is 
    signal result: unsigned(8 downto 0);
begin    
    process(reg_a_in, reg_b_in, op)
    begin
        if op = '0' then
            result <= resize(unsigned(reg_a_in), 9) + resize(unsigned(reg_b_in), 9);
        else
            result <= resize(unsigned(reg_a_in), 9) - resize(unsigned(reg_b_in), 9);
        end if;
    end process;

    carry_out <= result(8);
    zero_flag <= '1' when result(7 downto 0) = "00000000" else '0';
    result_out <= std_logic_vector(result(7 downto 0)) when en = '1' else (others => 'Z');  
end behave;
