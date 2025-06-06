# Minimalist color scheme
C_RESET="\033[0m"
C_BOLD="\033[1m"
C_BLUE="\033[34m"
C_GREEN="\033[32m"
C_RED="\033[31m"
C_YELLOW="\033[33m"

# Banner
banner() {
  clear
  cat << 'EOF'
███████╗████████╗███████╗ ██████╗ ██╗  ██╗██╗██████╗ ███████╗
██╔════╝╚══██╔══╝██╔════╝██╔════╝ ██║  ██║██║██╔══██╗██╔════╝
███████╗   ██║   █████╗  ██║  ███╗███████║██║██║  ██║█████╗  
╚════██║   ██║   ██╔══╝  ██║   ██║██╔══██║██║██║  ██║██╔══╝  
███████║   ██║   ███████╗╚██████╔╝██║  ██║██║██████╔╝███████╗
╚══════╝   ╚═╝   ╚══════╝ ╚═════╝ ╚═╝  ╚═╝╚═╝╚═════╝ ╚══════╝
EOF
  echo -e "${C_BLUE}${C_BOLD}Steghide Installer v1.0 by Joker${C_RESET}"
  echo
}

# Spinner for loading
spinner() {
  local pid=$1
  local frames=("⠋" "⠙" "⠹" "⠸" "⠼" "⠴" "⠦" "⠧")
  local i=0
  tput civis
  while kill -0 "$pid" 2>/dev/null; do
    printf "${C_YELLOW}${frames[i]} ${C_RESET}"
    i=$(( (i + 1) % ${#frames[@]} ))
    sleep 0.1
    printf "\b\b"
  done
  tput cnorm
  printf "\b\b"
}

redirect_to_website() {
  echo -e "${C_YELLOW}Redirecting to https://t.me/cyber_snipper...${C_RESET}"
  if command -v termux-open-url >/dev/null 2>&1; then
    termux-open-url "https://t.me/cyber_snipper" >/dev/null 2>&1
  elif command -v xdg-open >/dev/null 2>&1; then
    xdg-open "https://t.me/cyber_snipper" >/dev/null 2>&1
  elif command -v open >/dev/null 2>&1; then
    open "https://t.me/cyber_snipper" >/dev/null 2>&1
  else
    echo -e "${C_RED}Unable to open browser. Please visit https://t.me/cyber_snipper manually.${C_RESET}"
  fi
  sleep 2
}

# Run steghide after redirect
run_steghide() {
  redirect_to_website
  if check_steghide; then
    echo -e "${C_GREEN}Launching steghide...${C_RESET}"
    clear
    steghide
  else
    echo -e "${C_RED}Steghide not installed. Please install it first.${C_RESET}"
  fi
}

# Platform detection
detect_platform() {
  if [[ "$PREFIX" == *com.termux* ]]; then
    echo "termux"
  else
    echo "linux"
  fi
}

# Check for root privileges
check_root() {
  [[ "$(id -u)" -eq 0 ]]
}

# Check if steghide is installed
check_steghide() {
  command -v steghide >/dev/null 2>&1
}

# Install steghide on Termux
install_termux() {
  echo -e "${C_BLUE}Installing steghide on Termux...${C_RESET}"
  pkg update -y >/dev/null 2>&1 && pkg install -y steghide >/dev/null 2>&1 &
  spinner $!
  if check_steghide; then
    echo -e "${C_GREEN}Steghide installed successfully.${C_RESET}"
  else
    echo -e "${C_RED}Installation failed. Please try manually.${C_RESET}"
    return 1
  fi
}

# Install steghide on Linux
install_linux() {
  echo -e "${C_BLUE}Installing steghide on Linux...${C_RESET}"
  if command -v sudo >/dev/null 2>&1; then
    sudo apt-get update -y >/dev/null 2>&1 && sudo apt-get install -y steghide >/dev/null 2>&1 &
  else
    apt-get update -y >/dev/null 2>&1 && apt-get install -y steghide >/dev/null 2>&1 &
  fi
  spinner $!
  if check_steghide; then
    echo -e "${C_GREEN}Steghide installed successfully.${C_RESET}"
  else
    echo -e "${C_RED}Installation failed. Please try manually.${C_RESET}"
    return 1
  fi
}

# Main installer function
install_steghide() {
  if check_steghide; then
    echo -e "${C_YELLOW}Steghide is already installed.${C_RESET}"
    run_steghide
    return 0
  fi

  local platform
  platform=$(detect_platform)
  case "$platform" in
    termux)
      install_termux
      ;;
    linux)
      if check_root; then
        install_linux
      else
        echo -e "${C_RED}Root privileges required for Linux installation.${C_RESET}"
        echo -e "${C_YELLOW}Run as root or use sudo.${C_RESET}"
        return 1
      fi
      ;;
    *)
      echo -e "${C_RED}Unsupported platform.${C_RESET}"
      return 1
      ;;
  esac
}

# Main menu
main_menu() {
  while true; do
    banner
    echo -e "${C_BOLD}1 Install steghide${C_RESET}"
    echo -e "${C_BOLD}2 Exit${C_RESET}"
    echo
    read -p "Choose an option :" choice
    case "$choice" in
      1)
        install_steghide
        echo
        read -p "Press Enter to continue..."
        ;;
      2)
        run_steghide
        clear
        echo -e "${C_GREEN}Exiting installer.${C_RESET}"
        sleep 0.3
        exit 0
        ;;
      *)
        echo -e "${C_RED}Invalid option. Choose 1 or 2.${C_RESET}"
        sleep 0.5
        ;;
    esac
  done
}

# Run
main_menu
