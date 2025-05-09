#!/bin/bash

# ==================================================
# KONFIGURASI WARNA 
# ==================================================
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color
BOLD='\033[1m'

# ==================================================
# DEKLARASI VARIABEL
# ==================================================
declare -a stok=(90 78 75 45 52 77)
declare -a harga=(5000 10000 5000 5000 10000 10000)
declare -a items=("Soda" "Coklat" "Air Mineral" "Teh" "Matcha" "Kopi")
password="hey123"


# Fungsi untuk menampilkan header dengan animasi
display_header() {
    clear
    echo -e "${CYAN}"
    echo "=============================="
    echo -e "   ${BOLD} Mesin Minuman ${NC}${CYAN}   "
    echo "=============================="
    echo -e "${NC}"
}

# Fungsi untuk menampilkan daftar item dengan format tabel
display_items() {
    echo -e "${BOLD}No. Nama Item         Harga      Stok${NC}"
    for i in "${!items[@]}"; do
        printf "${GREEN}%2d. ${CYAN}%-15s ${YELLOW}Rp%-5d ${BLUE}(Stok: %d)${NC}\n" \
            $((i+1)) "${items[i]}" "${harga[i]}" "${stok[i]}"
    done
}

# Fungsi validasi input numerik dengan range
validate_input() {
    local input=$1
    local min=$2
    local max=$3

    # Validasi kosong
    [[ -z "$input" ]] && echo -e "${RED}Input tidak boleh kosong!${NC}" && return 1

    # Validasi numerik
    [[ ! $input =~ ^[0-9]+$ ]] && echo -e "${RED}Harus berupa angka!${NC}" && return 1

    # Validasi range
    if [[ -n "$min" ]] && (( input < min )); then
        echo -e "${RED}Input tidak boleh kurang dari $min!${NC}" 
        return 1
    fi
    
    if [[ -n "$max" ]] && (( input > max )); then
        echo -e "${RED}Input tidak boleh lebih dari $max!${NC}"
        return 1
    fi

    return 0
}

# Fungsi proses pembayaran dengan animasi
process_payment() {
    local index=$1
    local qty=$2
    local total=$((qty * harga[index]))
    
    echo -e "\n${BOLD}Detail Pembelian:${NC}"
    echo -e "${CYAN}Item:${NC} ${items[index]}"
    echo -e "${CYAN}Jumlah:${NC} $qty"
    echo -e "${CYAN}Total Harga:${NC} ${YELLOW}Rp$total${NC}"

    while true; do
        read -p "Masukkan uang yang dibayarkan (Rp): " payment
        
        # Validasi input pembayaran
        if validate_input "$payment" 1; then
            if (( payment >= total )); then
                local change=$((payment - total))
                stok[index]=$((stok[index] - qty))
                
                echo -e "\n${GREEN}----------------------${NC}"
                echo -e "-- Transaksi Berhasil!  --"
                echo -e "--------------------------------${NC}"
                (( change > 0 )) && echo -e "${CYAN}Kembalian:${NC} ${YELLOW}Rp$change${NC}"
                break
            else
                echo -e "${RED}Uang kurang! Kurang: Rp$((total - payment))${NC}"
                read -p "Tambahkan uang (y/n)? " choice
                case ${choice,,} in
                    n) 
                        echo -e "${YELLOW}Transaksi dibatalkan!${NC}"
                        return 1
                        ;;
                esac
            fi
        fi
    done
    read -p "${BOLD}Tekan enter untuk melanjutkan...${NC}"
}

# ==================================================
# MENU UTAMA
# ==================================================

# Fungsi menu pembelian
menu_pembelian() {
    while true; do
        display_header
        echo -e "${BOLD}=== MENU PEMBELIAN ===${NC}"
        display_items
        echo -e "\n${YELLOW}7. Kembali ke Menu Utama${NC}"
        
        while true; do
            read -p "Pilih item [1-6/7]: " choice
            if validate_input "$choice" 1 7; then break; fi
        done

        [ $choice -eq 7 ] && return
        
        local index=$((choice-1))
        if [ ${stok[index]} -gt 0 ]; then
            # Input jumlah pembelian
            while true; do
                read -p "Masukkan jumlah (Stok: ${stok[index]}): " qty
                if validate_input "$qty" 1 ${stok[index]}; then break; fi
            done

            # Konfirmasi pembelian
            read -p "Konfirmasi pembelian (y/n)? " confirm
            case ${confirm,,} in
                y) process_payment $index $qty ;;
                *) echo -e "${YELLOW}Transaksi dibatalkan!${NC}" ;;
            esac
        else
            echo -e "${RED}Stok habis!${NC}"
            read -p "Tekan enter untuk melanjutkan..."
        fi
    done
}

# Fungsi menu restok (admin)
menu_restok() {
    display_header
    echo -e "${BOLD}=== LOGIN ADMIN ===${NC}"
    read -s -p "Masukkan password: " pass
    echo
    
    if [ "$pass" != "$password" ]; then
        echo -e "${RED}Password salah!${NC}"
        read -p "Tekan enter untuk kembali..."
        return
    fi

    while true; do
        display_header
        echo -e "${BOLD}=== MENU RESTOK ===${NC}"
        display_items
        echo -e "\n${YELLOW}7. Kembali ke Menu Utama${NC}"
        
        while true; do
            read -p "Pilih item [1-6/7]: " choice
            if validate_input "$choice" 1 7; then break; fi
        done

        [ $choice -eq 7 ] && return
        
        local index=$((choice-1))
        # Input jumlah restok
        while true; do
            read -p "Masukkan jumlah tambahan stok: " add_stok
            if validate_input "$add_stok" 1; then break; fi
        done

        stok[index]=$((stok[index] + add_stok))
        echo -e "${GREEN}Stok berhasil ditambahkan!${NC}"
        read -p "Tekan enter untuk melanjutkan..."
    done
}


# Menu UTAMA

while true; do
    display_header
    
    echo -e "${BOLD}Pilihan Menu:${NC}"
    echo -e "${CYAN}1. Menu Pembelian"
    echo -e "2. Cek Stok"
    echo -e "3. Restok (Admin)"
    echo -e "4. Keluar${NC}"
    echo -e "${BOLD}===============================${NC}"
    
    while true; do
        read -p "Pilih menu [1-4]: " menu 
        echo -e "${BOLD}===============================${NC}"
        if validate_input "$menu" 1 4; then break; fi
    done
   
    case $menu in
        1) menu_pembelian ;;
        2) 
            display_header
            echo -e "${BOLD}=== CEK STOK ===${NC}"
            display_items
            read -p "Tekan enter untuk kembali..."
            ;;
        3) menu_restok ;;
        4) 
            echo -e "\n${GREEN}Terima kasih telah menggunakan layanan kami!${NC}"
            exit 0
            ;;
    esac
done