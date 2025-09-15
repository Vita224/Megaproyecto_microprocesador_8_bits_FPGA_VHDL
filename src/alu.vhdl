library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity alu is
    port(
        en: in STD_LOGIC; -- Habilita la salida funcional (control de lectura a nivel CPU)
        op: in STD_LOGIC; -- Operacion: 0 suma, 1 resta
        reg_a_in: in STD_LOGIC_VECTOR(7 downto 0);
        reg_b_in: in STD_LOGIC_VECTOR(7 downto 0);
        carry_out: out STD_LOGIC;
        zero_flag: out STD_LOGIC;
        result_out: out STD_LOGIC_VECTOR(7 downto 0)
    );
end entity;

architecture behave of alu is 
    signal result: unsigned(8 downto 0);
    signal res8: unsigned(7 downto 0);
begin    
    process(reg_a_in, reg_b_in, op)
    begin
        if op = '0' then
            result <= resize(unsigned(reg_a_in), 9) + resize(unsigned(reg_b_in), 9);
        else
            result <= resize(unsigned(reg_a_in), 9) - resize(unsigned(reg_b_in), 9);
        end if;
        res8 <= result(7 downto 0);
    end process;

    carry_out <= result(8);
    zero_flag <= '1' when res8 = to_unsigned(0, 8) else '0';
    -- Siempre conducido; el CPU decide si usar este dato segun alu_en_sig
    result_out <= std_logic_vector(res8);
end behave;
