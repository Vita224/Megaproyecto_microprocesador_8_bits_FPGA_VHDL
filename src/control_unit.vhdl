library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity control_unit is
    Port ( 
        clock : in std_logic;
        reset : in std_logic;
        instr : in std_logic_vector(3 downto 0);
        do    : out std_logic_vector(16 downto 0)
    );
end entity;

architecture behave of control_unit is
    signal counter: std_logic_vector(3 downto 0) := "0000";
begin

    -- Contador de ciclos
    count_proc: process(clock, reset)
    begin
        if reset = '1' then
            counter <= "0000";
        elsif rising_edge(clock) then
            if counter = "0110" then
                counter <= "0000";
            else
                counter <= std_logic_vector(unsigned(counter) + 1);
            end if;
        end if;
    end process;

    -- Generador de microcodigos
    microcode_proc: process(counter, instr)
    begin
        -- valor por defecto (evita latches)
        do <= (others => '0');

        case counter is
            ------------------------------------------------------------------
            when "0000" =>
                do <= "00000001100000000"; -- PC_OUT - MAR_IN (9 - 8)

            when "0001" =>
                do <= "00000100001000010"; -- PC_EN - RAM_OUT - instr_I

            ------------------------------------------------------------------
            -- LDA
            when "0010" =>
                if instr = "0000" then
                    do <= "00000000000000001"; -- instr_OUT
                elsif instr = "0001" then
                    do <= "00000000000000001"; -- STA: instr_OUT
                elsif instr = "0010" then
                    do <= "00000000000000001"; -- ADD: instr_OUT
                elsif instr = "0011" then
                    do <= "00000000000000001"; -- SUB: instr_OUT
                elsif instr = "0100" then
                    do <= "00000000000000001"; -- JMP: instr_OUT
                elsif instr = "0101" then
                    do <= "00000000000000001"; -- OUT: instr_OUT
                elsif instr = "0110" then
                    do <= "10000000000000000"; -- HLT
                end if;

            when "0011" =>
                if instr = "0000" then
                    do <= "00000000100000001"; -- LDA: MAR_IN - instr_OUT
                elsif instr = "0001" then
                    do <= "00000000100000001"; -- STA
                elsif instr = "0010" then
                    do <= "00000000100000001"; -- ADD
                elsif instr = "0011" then
                    do <= "00000000100000001"; -- SUB
                elsif instr = "0100" then
                    do <= "00000010000000001"; -- JMP
                elsif instr = "0101" then
                    do <= "00000000000010000"; -- OUT: A_OUT
                elsif instr = "0110" then
                    do <= "10000010000000000"; -- HLT
                end if;

            when "0100" =>
                if instr = "0000" then
                    do <= "00000000001100000"; -- LDA: RAM_OUT - A_IN
                elsif instr = "0001" then
                    do <= "00000000010010000"; -- STA: A_OUT + RAM_IN
                elsif instr = "0010" then
                    do <= "00000000001001000"; -- ADD: RAM_OUT - B_IN
                elsif instr = "0011" then
                    do <= "00000000001001000"; -- SUB: RAM_OUT - B_IN
                elsif instr = "0101" then
                    do <= "01000000000010000"; -- OUT_IN - A_OUT
                end if;

            when "0101" =>
                if instr = "0010" then
                    do <= "00001000000000000"; -- ADD: ALU_EN
                elsif instr = "0011" then
                    do <= "00010000000000000"; -- SUB: ALU_OP_EN
                end if;

            when "0110" =>
                if instr = "0010" then
                    do <= "00001000000100000"; -- ADD: ALU_EN - A_IN
                elsif instr = "0011" then
                    do <= "00011000000100000"; -- SUB: ALU_OP_EN - ALU_EN - A_IN
                elsif instr = "0101" then
                    do <= "00100000000000000"; -- OUT_OUT
                end if;

            ------------------------------------------------------------------
            when others =>
                do <= (others => '0');
        end case;
    end process;

end behave;
