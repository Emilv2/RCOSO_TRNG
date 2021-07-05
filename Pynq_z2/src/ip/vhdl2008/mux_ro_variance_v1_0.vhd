
library ieee;
  use ieee.std_logic_1164.all;
  use ieee.numeric_std.all;
  use ieee.std_logic_unsigned.all;

library coso_lib;
  use coso_lib.mux_p;

entity mux_ro_variance_v1_0 is
  generic (
    -- Users to add parameters here

    -- User parameters ends
    -- Do not modify the parameters beyond this line

    -- Parameters of Axi Slave Bus Interface S00_AXI
    C_S00_AXI_DATA_WIDTH : integer := 32;
    C_S00_AXI_ADDR_WIDTH : integer := 4;

    -- Parameters of Axi Master Bus Interface M00_AXIS
    C_M00_AXIS_TDATA_WIDTH : integer := 32;
    C_M00_AXIS_START_COUNT : integer := 32
  );
  port (
    -- Users to add ports here

    -- User ports ends
    -- Do not modify the ports beyond this line

    -- Ports of Axi Slave Bus Interface S00_AXI
    -- vsg_off port_025
    s00_axi_aclk    : in    std_logic;
    s00_axi_aresetn : in    std_logic;
    s00_axi_awaddr  : in    std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
    s00_axi_awprot  : in    std_logic_vector(2 downto 0);
    s00_axi_awvalid : in    std_logic;
    s00_axi_awready : out   std_logic;
    s00_axi_wdata   : in    std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
    s00_axi_wstrb   : in    std_logic_vector((C_S00_AXI_DATA_WIDTH / 8) - 1 downto 0);
    s00_axi_wvalid  : in    std_logic;
    s00_axi_wready  : out   std_logic;
    s00_axi_bresp   : out   std_logic_vector(1 downto 0);
    s00_axi_bvalid  : out   std_logic;
    s00_axi_bready  : in    std_logic;
    s00_axi_araddr  : in    std_logic_vector(C_S00_AXI_ADDR_WIDTH - 1 downto 0);
    s00_axi_arprot  : in    std_logic_vector(2 downto 0);
    s00_axi_arvalid : in    std_logic;
    s00_axi_arready : out   std_logic;
    s00_axi_rdata   : out   std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
    s00_axi_rresp   : out   std_logic_vector(1 downto 0);
    s00_axi_rvalid  : out   std_logic;
    s00_axi_rready  : in    std_logic;

    -- Ports of Axi Master Bus Interface M00_AXIS
    m00_axis_aclk    : in    std_logic;
    m00_axis_aresetn : in    std_logic;
    m00_axis_tvalid  : out   std_logic;
    m00_axis_tdata   : out   std_logic_vector(C_M00_AXIS_TDATA_WIDTH - 1 downto 0);
    m00_axis_tstrb   : out   std_logic_vector((C_M00_AXIS_TDATA_WIDTH / 8) - 1 downto 0);
    m00_axis_tlast   : out   std_logic;
    m00_axis_tready  : in    std_logic
    -- vsg_on port_025
  );
end entity mux_ro_variance_v1_0;

architecture arch_imp of mux_ro_variance_v1_0 is

  -- signal s_control       : std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
  -- signal s_control_test  : std_logic_vector(C_S00_AXI_DATA_WIDTH - 1 downto 0);
  signal s_start_counter : integer range 0 to C_M00_AXIS_START_COUNT;

  signal s_data          : std_logic_vector(C_M00_AXIS_TDATA_WIDTH - 1 downto 0);
  signal s_data_buffer   : std_logic_vector(C_M00_AXIS_TDATA_WIDTH - 1 downto 0);
  signal s_tlast_counter : std_logic_vector(C_M00_AXIS_TDATA_WIDTH - 1 downto 0);

  constant MAX_CNT      : integer := 4194304 - 1;
  constant MAX_NB_TLAST : integer := 1;
  constant COUNT_WIDTH  : integer := 16;
  constant COUNT_DIV    : integer := 1000;

  type t_state is (
    WAITING_1,
    WAITING_2,
    IDLE,
    INIT_COUNTER,
    WAIT_FOR_VALID_LOW_1,
    WAIT_FOR_VALID_LOW_2,
    WAIT_FOR_VALID,
    FILL_BUFFER,
    SEND_STREAM
  );

  -- stream data is output through M_AXIS_TDATA
  signal s_state : t_state;

  constant NB_RO              : natural := 32;
  signal   s_ro_out           : mux_p.slv_array_t(NB_RO - 1 downto 0)(0 downto 0);
  signal   s_vec_enable       : std_logic_vector(NB_RO - 1 downto 0);
  signal   s_array_enable     : mux_p.slv_array_t(NB_RO - 1 downto 0)(0 downto 0);
  signal   s_enable           : std_logic_vector(0 downto 0);
  signal   s_counter_rst      : std_logic;
  signal   s_counter_overflow : std_logic;
  signal   s_ro_counter       : mux_p.slv_array_t(NB_RO - 1 downto 0)(29 downto 0);
  signal   s_ro_counter2      : std_logic_vector(31 downto 0);

  signal s_sel_cscnt     : std_logic;
  signal s_sel_ro        : std_logic;
  signal s_dma_done      : std_logic;
  signal s_ack           : std_logic;
  signal s_valid_d       : std_logic;
  signal s_valid_dd      : std_logic;
  signal s_valid_ddd     : std_logic;
  -- signal s_cscnt_valid   : mux_p.slv_array_t(NB_RO - 1 downto 0)(0 downto 0);
  signal s_rand          : mux_p.slv_array_t(NB_RO - 1 downto 0)(1 downto 0);
  signal s_select        : std_logic_vector(5 downto 0);
  signal s_open          : std_logic_vector(10 downto 0);
  signal s_open2         : std_logic_vector(11 downto 0);
  signal s_counter       : unsigned(28 downto 0);
  signal s_data_to_ps0   : std_logic_vector(31 downto 0);
  signal s_data_to_ps1   : std_logic_vector(31 downto 0);
  signal s_data_from_ps0 : std_logic_vector(31 downto 0);
  signal s_data_from_ps1 : std_logic_vector(31 downto 0);

  signal s_speed_count  : integer;
  signal s_count_enable : std_logic;
  signal s_count_done   : std_logic;

  signal s_valid  : std_logic_vector(NB_RO - 1 downto 0);
  signal s_failed : std_logic_vector(NB_RO - 1 downto 0);

begin

  -- Instantiation of Axi Bus Interface S00_AXI
  mux_ro_variance_v1_0_ss_00_axi_inst : entity coso_lib.mux_ro_variance_v1_0_s00_axi
    generic map (
      c_s_axi_data_width => C_S00_AXI_DATA_WIDTH,
      c_s_axi_addr_width => C_S00_AXI_ADDR_WIDTH
    )
    port map (
      data_from_ps0_o(31 downto 31) => s_enable,
      data_from_ps0_o(30 downto 25) => s_select,
      data_from_ps0_o(24 downto 14) => s_open,
      data_from_ps0_o(13)           => s_sel_ro,
      data_from_ps0_o(12)           => s_sel_cscnt,
      data_from_ps0_o(11 downto 0)  => s_open2,
      -- data_from_ps0_o(11 downto 6)  => s_control_0,
      -- data_from_ps0_o(5 downto 0)   => s_control_1,
      data_from_ps1_o               => s_data_from_ps1,
      data_to_ps0_i                 => s_data_to_ps0,
      data_to_ps1_i                 => s_data_to_ps1,
      s_axi_aclk                    => s00_axi_aclk,
      s_axi_aresetn                 => s00_axi_aresetn,
      s_axi_awaddr                  => s00_axi_awaddr,
      s_axi_awprot                  => s00_axi_awprot,
      s_axi_awvalid                 => s00_axi_awvalid,
      s_axi_awready                 => s00_axi_awready,
      s_axi_wdata                   => s00_axi_wdata,
      s_axi_wstrb                   => s00_axi_wstrb,
      s_axi_wvalid                  => s00_axi_wvalid,
      s_axi_wready                  => s00_axi_wready,
      s_axi_bresp                   => s00_axi_bresp,
      s_axi_bvalid                  => s00_axi_bvalid,
      s_axi_bready                  => s00_axi_bready,
      s_axi_araddr                  => s00_axi_araddr,
      s_axi_arprot                  => s00_axi_arprot,
      s_axi_arvalid                 => s00_axi_arvalid,
      s_axi_arready                 => s00_axi_arready,
      s_axi_rdata                   => s00_axi_rdata,
      s_axi_rresp                   => s00_axi_rresp,
      s_axi_rvalid                  => s00_axi_rvalid,
      s_axi_rready                  => s00_axi_rready
    );

  -- Add user logic here

  gen_ro : for i in 0 to NB_RO - 1 generate

    trng_inst : entity coso_lib.trng
      port map (
        clk_i         => m00_axis_aclk,
        ack_i         => s_ack,
        enable_i      => s_vec_enable(i),
        valid_o       => s_valid(i),
        failed_o      => s_failed(i),
        rand_o        => s_rand(i)
      );

  end generate gen_ro;

  demux_0 : entity coso_lib.demux
    generic map (
      len => 1,
      num => NB_RO
    )
    port map (
      v_i   => s_enable,
      sel_i => to_integer(unsigned(s_select)),
      z_o   => s_array_enable
    );

  inp_concat_loop : for i in 0 to NB_RO - 1 generate
    s_vec_enable(i) <= s_array_enable(i)(0);
  end generate inp_concat_loop;

  counter_inst_1 : entity coso_lib.async_counter
    generic map (
      max => 100_000_000
    )
    port map (
      clk_i      => m00_axis_aclk,
      rst_i      => '0',
      overflow_o => s_counter_overflow,
      counter_o  => s_ro_counter2(26 downto 0)
    );

  send_data : process (s00_axi_aclk) is
  begin

    if (rising_edge(s00_axi_aclk)) then
      s_data_to_ps0(31) <= s_dma_done;
      s_data_to_ps0(30) <= s_valid(to_integer(unsigned(s_select)));
      s_data_to_ps0(29) <= s_failed(to_integer(unsigned(s_select)));
      if (s_counter_overflow = '1') then
        s_data_to_ps1              <= "00" & s_ro_counter(to_integer(unsigned(s_select)));
        s_data_to_ps0(28 downto 0) <= std_logic_vector(s_counter);
        s_counter                  <= s_counter + 1;
        s_counter_rst              <= '1';
      elsif (s_dma_done = '1') then
        s_data_to_ps1              <= std_logic_vector(to_unsigned(s_speed_count, s_data_to_ps1'length));
      else
        s_counter_rst <= '0';
      end if;
    end if;

  end process send_data;

  m00_axis_tdata <= s_data;

  synchronization : process (m00_axis_aclk) is
  begin

    if (rising_edge(m00_axis_aclk)) then
         s_valid_d <= s_valid(to_integer(unsigned(s_select)));
         s_valid_dd <= s_valid_d;
         s_valid_ddd <= s_valid_dd;
    end if;

  end process synchronization;

  speed_count : process (m00_axis_aclk) is

    variable v_count_div : integer range 0 to COUNT_DIV;

  begin

    if (rising_edge(m00_axis_aclk)) then
      if (m00_axis_aresetn = '0') then
        v_count_div := 0;
        s_speed_count  <= 0;
      elsif (s_count_done = '1') then
        v_count_div := 0;
        s_speed_count  <= 0;
      elsif (s_count_enable = '1') then
        v_count_div := v_count_div + 1;
        if (v_count_div = COUNT_DIV) then
          s_speed_count <= s_speed_count + 1;
          v_count_div := 0;
        end if;
      end if;
    end if;

  end process speed_count;

  dma : process (m00_axis_aclk) is

    variable v_nb_tlast     : integer range 0 to MAX_NB_TLAST;
    variable v_buffer_count : integer range 0 to C_M00_AXIS_TDATA_WIDTH - 1;

  begin

    if (rising_edge(m00_axis_aclk)) then
      if (m00_axis_aresetn = '0') then
        m00_axis_tvalid <= '0';
        s_data          <= (others => '0');
        s_start_counter <= 0;
        s_state         <= WAITING_1;
        v_nb_tlast     := 0;
        v_buffer_count := 0;
      else

        case (s_state) is

          when WAITING_1 =>
            s_dma_done      <= '1';
            m00_axis_tvalid <= '0';
            m00_axis_tlast  <= '0';
            s_ack           <= '0';
            s_count_done    <= '0';
            s_count_enable  <= '0';
            if (s_sel_cscnt = '0') then
              s_state <= WAITING_2;
            end if;

          when WAITING_2 =>
            s_dma_done      <= '0';
            m00_axis_tvalid <= '0';
            m00_axis_tlast  <= '0';
            s_ack           <= '0';
            s_count_done    <= '0';
            s_count_enable  <= '0';
            if (s_sel_cscnt = '1') then
              s_state <= IDLE;
            end if;

          when IDLE =>
            s_dma_done      <= '0';
            m00_axis_tvalid <= '0';
            m00_axis_tlast  <= '0';
            s_ack           <= '0';
            s_count_done    <= '0';
            s_count_enable  <= '0';
            s_start_counter <= 0;
            s_state         <= INIT_COUNTER;

          when INIT_COUNTER =>
            s_dma_done      <= '0';
            m00_axis_tvalid <= '0';
            m00_axis_tlast  <= '0';
            s_ack           <= '0';
            s_count_done    <= '1';
            s_count_enable  <= '0';
            s_start_counter <= s_start_counter + 1;
            if (s_start_counter = C_M00_AXIS_START_COUNT) then
              s_state    <= WAIT_FOR_VALID;
            end if;

          when WAIT_FOR_VALID_LOW_1 =>
            s_dma_done      <= '0';
            m00_axis_tvalid <= '0';
            m00_axis_tlast  <= '0';
            s_count_done    <= '0';
            s_count_enable  <= '1';
            s_ack   <= '0';
            s_state <= WAIT_FOR_VALID_LOW_2;

          when WAIT_FOR_VALID_LOW_2 =>
            s_dma_done      <= '0';
            m00_axis_tvalid <= '0';
            m00_axis_tlast  <= '0';
            s_count_done    <= '0';
            s_count_enable  <= '1';
            if (s_valid_ddd = '0') then
              s_state <= WAIT_FOR_VALID;
              s_ack   <= '0';
            else
              s_ack   <= '1';
            end if;

          when WAIT_FOR_VALID =>
            s_dma_done      <= '0';
            m00_axis_tvalid <= '0';
            m00_axis_tlast  <= '0';
            s_ack           <= '0';
            s_count_done    <= '0';
            s_count_enable  <= '1';
            if (s_valid_ddd = '1') then
              s_state <= FILL_BUFFER;
            end if;

          when FILL_BUFFER =>
            s_dma_done      <= '0';
            m00_axis_tvalid <= '0';
            m00_axis_tlast  <= '0';
            s_ack           <= '0';
            --if (s_valid_ddd = '1') and (to_integer(unsigned(s_cscnt(to_integer(unsigned(s_select))))) > 30) then
            if (s_valid_ddd = '1') then
              s_data_buffer(v_buffer_count) <= s_rand(to_integer(unsigned(s_select)))(0);
              s_data_buffer(v_buffer_count + 1) <= s_rand(to_integer(unsigned(s_select)))(1);
              if (v_buffer_count + 1 = C_M00_AXIS_TDATA_WIDTH - 1) then
                s_state <= SEND_STREAM;
                v_buffer_count := 0;
              else
                v_buffer_count := v_buffer_count + 2;
                s_state <= WAIT_FOR_VALID_LOW_1;
              end if;
            elsif (s_valid_ddd = '1') then
                s_state <= WAIT_FOR_VALID_LOW_1;
            end if;


          when SEND_STREAM =>
            if (m00_axis_tready = '1') then
                m00_axis_tvalid <= '1';
              if (unsigned(s_tlast_counter) = MAX_CNT) then
                  m00_axis_tlast  <= '1';
                  s_tlast_counter <= (others => '0');
                v_nb_tlast := v_nb_tlast + 1;
              else
                  m00_axis_tlast  <= '0';
                  s_tlast_counter <= std_logic_vector(unsigned(s_tlast_counter) + 1);
              end if;
              if (v_nb_tlast >= MAX_NB_TLAST) then
                v_nb_tlast := 0;
                  s_state    <= WAITING_1;
                  s_dma_done <= '1';
                  s_count_done    <= '0';
                  s_count_enable  <= '0';
              else
                  s_state    <= WAIT_FOR_VALID_LOW_1;
                  s_ack      <= '0';
                  s_count_done    <= '0';
                  s_count_enable  <= '1';
              end if;
                s_data <= s_data_buffer;
            else
              s_dma_done      <= '0';
              m00_axis_tvalid <= '0';
              m00_axis_tlast  <= '0';
              s_ack           <= '0';
              s_count_done    <= '0';
              s_count_enable  <= '1';
            end if;

          when others =>
            s_state <= WAITING_1;

        end case;

      end if;
    end if;

  end process dma;

end architecture arch_imp;
