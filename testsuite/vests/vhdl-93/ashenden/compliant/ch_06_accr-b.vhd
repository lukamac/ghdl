
-- Copyright (C) 1996 Morgan Kaufmann Publishers, Inc

-- This file is part of VESTs (Vhdl tESTs).

-- VESTs is free software; you can redistribute it and/or modify it
-- under the terms of the GNU General Public License as published by the
-- Free Software Foundation; either version 2 of the License, or (at
-- your option) any later version. 

-- VESTs is distributed in the hope that it will be useful, but WITHOUT
-- ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
-- FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
-- for more details. 

-- You should have received a copy of the GNU General Public License
-- along with VESTs; if not, write to the Free Software Foundation,
-- Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA 

-- ---------------------------------------------------------------------
--
-- $Id: ch_06_accr-b.vhd,v 1.2 2001-10-26 16:29:34 paw Exp $
-- $Revision: 1.2 $
--
-- ---------------------------------------------------------------------

architecture behavioral of accumulator_reg is
begin

  behavior : process (clk) is

                             constant Tpd_clk_out : time := 3 ns;

  begin
    if rising_edge(clk) then
      if To_X01(clr) = '1' then
        q <= (others => '0') after Tpd_clk_out;
      else
        q <= d after Tpd_clk_out;
      end if;
    end if;
  end process behavior;

end architecture behavioral;
