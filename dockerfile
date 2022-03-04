FROM centos:8
MAINTAINER SmartBrave <SmartBraveCoder@gmail.com>

#build command: docker build -t ${USER_NAME}/${IMAGE_NAME}:${VERSION} --build-arg NORMAL_USER=${NORMAL_USER} --build-arg NORMAL_PASSWD=${NORMAL_PASSWD} --build-arg ROOT_PASSWD=${ROOT_PASSWD} .
#run command:   docker exec -it `docker run -d --name ${dev-linux-env} --privileged=true ${USER_NAME}/${IMAGE_NAME}:${VERSION}` /bin/bash
#suggection:    If you want to mount volumns on MacOS, use mutagen or docker-sync instead of -v args.

ARG  NORMAL_USER=test_user
ARG  NORMAL_PASSWD=test_passwd
ARG  ROOT_PASSWD=root_passwd

#https://github.com/alebcay/awesome-shell

ENV GOPATH=/home/$NORMAL_USER/code/ \
    CLONE_PATH=/usr/local/src \
    APP_PATH=/usr/local/app \
    BIN_PATH=/usr/local/bin

RUN    sed -i 's/mirrorlist/#mirrorlist/g' /etc/yum.repos.d/CentOS-* \
    && sed -i 's|#baseurl=http://mirror.centos.org|baseurl=http://vault.centos.org|g' /etc/yum.repos.d/CentOS-*

RUN    dnf -y install dnf-plugins-core \
    && dnf config-manager --set-enabled powertools \
    && dnf config-manager --add-repo https://cli.github.com/packages/rpm/gh-cli.repo \
    && dnf localinstall -y https://download1.rpmfusion.org/free/el/rpmfusion-free-release-7.noarch.rpm \
    && dnf -y update \
    && dnf -y install epel-release \
    && dnf -y install libgcc.i686 glibc-devel bison flex texinfo libtool \
          zlib-devel bzip2-devel openssl-devel sqlite-devel readline-devel tk-devel \
          gdbm-devel xz-devel gettext pkg-config autoconf automake txt2man ncurses ncurses-devel \
          tcl-devel net-tools llvm clang-libs clang-devel which libX11-devel libXcursor-devel libXrandr-devel \
          libXinerama-devel mesa-libGL-devel mesa-libGLU-devel freeglut-devel libXi-devel libevent \
          libevent-devel asciidoc pcre-devel xz-devel bind-utils freetype-devel glib2-devel fontconfig-devel \
          pango-devel libwebp-devel libde265  libheif* privoxy initscripts cscope \
    && dnf -y install libpng libpng-devel libjpeg-devel ghostscript-devel \
          libtiff-devel libwmf-devel \
    && dnf -y groupinstall "Development Tools" \
    && dnf -y install git sudo gcc gcc-c++ gdb make unzip ctags vim expect passwd wget cmake figlet ncdu \
        nnn gh kakoune colordiff \
    && dnf -y install perl nodejs rust python2 python2-pip python2-devel \
          python3 python3-pip python3-devel ruby lua luajit zsh \
    && ln -s /usr/bin/python3 /usr/bin/python \
       && ln -s /usr/bin/pip3 /usr/bin/pip \
    && sed -i '/Defaults/s/env_reset/\!env_reset/g' /etc/sudoers \
    && useradd --create-home $NORMAL_USER --password $NORMAL_PASSWD && echo "$NORMAL_USER ALL=(ALL) NOPASSWD:ALL" >>/etc/sudoers \
    && echo "root:$ROOT_PASSWD" | chpasswd \
    && mkdir ${APP_PATH} \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime

RUN    git clone https://github.com/ImageMagick/ImageMagick ${CLONE_PATH}/ImageMagick \
       && cd ${CLONE_PATH}/ImageMagick \
       && ./configure --prefix=${APP_PATH}/ImageMagick --with-heic=yes --with-jxl=yes --with-jpeg=yes --with-png=yes --with-webp=yes \
       && make -j 10 \
       && make install \
       && ln -s ${APP_PATH}/ImageMagick/bin/magick ${BIN_PATH}/magick \
       && ln -s ${APP_PATH}/ImageMagick/bin/animate ${BIN_PATH}/animate \
       && ln -s ${APP_PATH}/ImageMagick/bin/compare ${BIN_PATH}/compare \
       && ln -s ${APP_PATH}/ImageMagick/bin/composite ${BIN_PATH}/composite \
       && ln -s ${APP_PATH}/ImageMagick/bin/conjure ${BIN_PATH}/conjure \
       && ln -s ${APP_PATH}/ImageMagick/bin/convert ${BIN_PATH}/convert \
       && ln -s ${APP_PATH}/ImageMagick/bin/display ${BIN_PATH}/display \
       && ln -s ${APP_PATH}/ImageMagick/bin/identify ${BIN_PATH}/identify \
       && ln -s ${APP_PATH}/ImageMagick/bin/import ${BIN_PATH}/import \
       && ln -s ${APP_PATH}/ImageMagick/bin/magick-script ${BIN_PATH}/magick-script \
       && ln -s ${APP_PATH}/ImageMagick/bin/mogrify ${BIN_PATH}/mogrify \
       && ln -s ${APP_PATH}/ImageMagick/bin/montage ${BIN_PATH}/montage \
       && ln -s ${APP_PATH}/ImageMagick/bin/stream ${BIN_PATH}/stream

RUN    cd ${CLONE_PATH} \
       && curl -OL https://github.com/wagoodman/dive/releases/download/v0.9.2/dive_0.9.2_linux_amd64.rpm \
       && rpm -i dive_0.9.2_linux_amd64.rpm

RUN    cd ${CLONE_PATH} \
       && wget https://github.com/rgburke/grv/releases/download/v0.3.2/grv_v0.3.2_linux64 \
       && chmod +x grv_v0.3.2_linux64 \
       && cp grv_v0.3.2_linux64 ${APP_PATH}/grv

RUN    wget https://github.com/axel-download-accelerator/axel/releases/download/v2.17.7/axel-2.17.7.tar.gz -O ${CLONE_PATH}/axel-2.17.7.tar.gz \
       && cd ${CLONE_PATH} \
       && tar -zxvf axel-2.17.7.tar.gz \
       && cd axel-2.17.7 \
       && cd ${CLONE_PATH}/axel-2.17.7 \
       && ./configure --prefix=${APP_PATH}/axel-2.17.7 \
       && make -j 10 \
       && make install \
       && ln -s ${APP_PATH}/axel-2.17.7/bin/axel ${BIN_PATH}/axel

RUN    sudo git clone https://github.com/jarun/bcal ${CLONE_PATH}/bcal \
       && cd ${CLONE_PATH}/bcal \
       && make -j 10 \
       && make strip install

RUN    sudo git clone https://github.com/so-fancy/diff-so-fancy ${CLONE_PATH}/diff-so-fancy \
       && ln -s ${CLONE_PATH}/diff-so-fancy/diff-so-fancy ${BIN_PATH}/diff-so-fancy

RUN    git clone https://github.com/clvv/fasd ${CLONE_PATH}/fasd \
       && cd ${CLONE_PATH}/fasd \
       && make install

RUN    git clone https://github.com/dylanaraps/fff ${CLONE_PATH}/fff \
       && cd ${CLONE_PATH}/fff \
       && make PREFIX=${APP_PATH}/fff install \
       && ln -s ${APP_PATH}/fff/bin/fff ${BIN_PATH}/fff

RUN    git clone https://github.com/golbin/git-commander ${CLONE_PATH}/git-commander \
       && cd ${CLONE_PATH}/git-commander \
       && npm -g install blessed lodash git-commander

RUN    git clone https://github.com/hishamhm/htop ${CLONE_PATH}/htop \
       && cd ${CLONE_PATH}/htop \
       && ./autogen.sh \
       && ./configure --prefix=${APP_PATH}/htop \
       && make -j 10 \
       && make install \
       && ln -s ${APP_PATH}/htop/bin/htop ${BIN_PATH}/htop

RUN    curl -L https://bit.ly/glances | /bin/bash

RUN    git clone https://github.com/stedolan/jq ${CLONE_PATH}/jq \
       && cd ${CLONE_PATH}/jq \
       && git submodule update --init \
       && autoreconf -fi \
       && ./configure --prefix=${APP_PATH}/jq --with-oniguruma=builtin \
       && make -j 10 \
       && make check \
       && make install \
       && ln -s ${APP_PATH}/jq/bin/jq ${BIN_PATH}/jq

RUN    git clone https://github.com/hackerb9/lsix ${CLONE_PATH}/lsix \
       && cd ${CLONE_PATH}/lsix \
       && ln -s ${CLONE_PATH}/lsix ${BIN_PATH}/lsix

RUN    git clone https://github.com/facebook/PathPicker ${CLONE_PATH}/PathPicker \
       && cd ${CLONE_PATH}/PathPicker \
       && ln -s fpp ${BIN_PATH}/fpp

RUN    git clone https://github.com/jonas/tig ${CLONE_PATH}/tig \
       && cd ${CLONE_PATH}/tig \
       && make prefix=${APP_PATH}/tig \
       && make install prefix=${APP_PATH}/tig \
       && ln -s ${APP_PATH}/tig/bin/tig ${BIN_PATH}/tig

RUN    git clone https://github.com/tmux/tmux ${CLONE_PATH}/tmux \
       && cd ${CLONE_PATH}/tmux \
       && sh autogen.sh \
       && ./configure --prefix=${APP_PATH}/tmux \
       && make -j 10 \
       && make install \
       && ln -s ${APP_PATH}/tmux/bin/tmux ${BIN_PATH}/tmux

RUN    git clone https://github.com/andreafrancia/trash-cli ${CLONE_PATH}/trash-cli \
       && cd ${CLONE_PATH}/trash-cli \
       && python setup.py install

RUN    git clone https://github.com/vifm/vifm ${CLONE_PATH}/vifm \
       && cd ${CLONE_PATH}/vifm \
       && ./scripts/fix-timestamps \
       && ./configure --prefix=${APP_PATH}/vifm \
       && make \
       && make install \
       && ln -s ${APP_PATH}/vifm/bin/vifm ${BIN_PATH}/vifm

RUN    git clone https://github.com/mptre/yank ${CLONE_PATH}/yank \
       && cd ${CLONE_PATH}/yank \
       && make PREFIX=${APP_PATH}/yank install \
       && ln -s ${APP_PATH}/yank/bin/yank ${BIN_PATH}/yank

RUN    cd ${CLONE_PATH} \
       && wget https://github.com/sharkdp/insect/releases/download/v5.3.0/insect-linux-x64 \
       && ln -s ./insect-linux-x64 ${BIN_PATH}/insect

RUN    cd ${CLONE_PATH} \
       && wget https://github.com/koalaman/shellcheck/releases/download/stable/shellcheck-stable.linux.x86_64.tar.xz \
       && tar xf shellcheck-stable.linux.x86_64.tar.xz \
       && ln -s ./shellcheck-stable/shellcheck ${BIN_PATH}/shellcheck

RUN    cd ${CLONE_PATH} \
       && curl -OL https://raw.github.com/nvie/gitflow/develop/contrib/gitflow-installer.sh \
       && chmod +x gitflow-installer.sh \
       && REPO_HOST=git@github.com:nvie/gitflow ./gitflow-installer.sh

RUN    git clone https://github.com/ggreer/the_silver_searcher ${CLONE_PATH}/the_silver_searcher \
       && cd ${CLONE_PATH}/the_silver_searcher \
       && ./build.sh \
       && make install

RUN    git clone https://github.com/beyondgrep/ack2 ${CLONE_PATH}/ack2 \
       && cpan install File::Next \
       && cd ${CLONE_PATH}/ack2 \
       && perl Makefile.PL \
       && make \
       && make test \
       && make install

RUN    git clone https://git.ffmpeg.org/ffmpeg.git ${CLONE_PATH}/ffmpeg \
       && cd ${CLONE_PATH}/ffmpeg \
       && ./configure --prefix=${APP_PATH}/ffmpeg --enable-openssl --disable-x86asm \
       && make -j 10 \
       && make install \
       && sudo ln -s ${APP_PATH}/ffmpeg/bin/ffmpeg ${BIN_PATH}/ffmpeg \
       && sudo ln -s ${APP_PATH}/ffmpeg/bin/ffprobe ${BIN_PATH}/ffprobe

RUN    git clone https://github.com/vim/vim.git ${CLONE_PATH} \
       && cd ${CLONE_PATH/vim \
       && ./configure --prefix=/usr/local/app/vim --with-features=huge --enable-multibyte --enable-python3interp=yes --with-python3-config-dir=/usr/lib64/python3.6/config-3.6m-x86_64-linux-gnu --enable-gui=gtk2 --enable-cscope \
       && make -j6 \
       && make install \
       && mv /usr/bin/vim /usr/bin/vim.bak \
       && ln -s $(pwd)/bin/vim /usr/local/bin/vim \
       && ln -s $(pwd)/bin/vimdiff /usr/local/bin/vimdiff \
       && hash -r

RUN    curl -LSfs https://raw.githubusercontent.com/cantino/mcfly/master/ci/install.sh | sh -s -- --git cantino/mcfly

#python
RUN    pip install --upgrade setuptools \
       && python -m pip install --upgrade pip

RUN    pip3 install pybind11 git+https://github.com/jeffkaufman/icdiff.git iredis ranger-fm mdv thefuck mycli asciinema http-prompt yapf \
    && pip3 install --upgrade httpie \
    && pip2 install pybind11
# RUN    pip install manimgl

#nodejs
RUN    npm install -g fx fx-completion cloc svg-term-cli zx

RUN    chmod a+w ${CLONE_PATH} \
       && chmod a+w ${APP_PATH} \
       && chown -R $NORMAL_USER $GOPATH #TODO

#RUN    usermod -u 501 $NORMAL_USER
USER   $NORMAL_USER
WORKDIR /home/$NORMAL_USER

RUN    git clone https://github.com/adwpc/xvim.git ${CLONE_PATH}/xvim \
       && cd ${CLONE_PATH}/xvim \
       && yes | ./install vimrc

RUN    git clone https://github.com/SmartBrave/dev-env-linux ${CLONE_PATH}/dev-env-linux \
       && cd ${CLONE_PATH}/dev-env-linux \
       && cp .bash_profile .bashrc .gitconfig .tigrc .tmux.conf .vimrc ~ \
       && vim +PluginInstall +qall
       #need to install vim plugins after login, reference to https://github.com/adwpc/xvim

#go
RUN    cd ${CLONE_PATH} \
       && sudo wget https://dl.google.com/go/go1.17.6.linux-amd64.tar.gz \
       && sudo tar -zxvf go1.17.6.linux-amd64.tar.gz -C ${APP_PATH} \
       && sudo ln -s ${APP_PATH}/go/bin/go ${BIN_PATH}/go \
       && sudo ln -s ${APP_PATH}/go/bin/gofmt ${BIN_PATH}/gofmt \
    && go get -u -v github.com/tomnomnom/gron \
    && go get -u -v github.com/jingweno/ccat \
    && go get -u -v github.com/go-delve/delve/cmd/dlv \
    && go get -u -v github.com/peco/peco \
    && go get -u -v github.com/mikefarah/yq/v3 \
    && go get -u -v github.com/cheat/cheat/cmd/cheat \
    && go install github.com/wader/fq@latest \
    && go get -u -v github.com/jesseduffield/lazydocker
    #&& go get -u -v github.com/liamg/aminal \

RUN    git clone https://github.com/kevinschoon/pomo.git ${CLONE_PATH}/pomo \
       && cd ${CLONE_PATH}/pomo \
       && make

RUN    git clone https://github.com/charmbracelet/glow.git ${CLONE_PATH}/glow \
       && cd ${CLONE_PATH}/glow \
       && go build

RUN    git clone https://github.com/rs/curlie.git ${CLONE_PATH}/curlie \
       && cd ${CLONE_PATH}/curlie \
       && go install

RUN    git clone https://github.com/muesli/duf.git ${CLONE_PATH}/duf \
       && cd ${CLONE_PATH}/duf \
       && go install

RUN    ssh-keygen -t rsa -N "" -f ~/.ssh/id_rsa

RUN    git clone https://github.com/wting/autojump ${CLONE_PATH}/autojump \
       && cd ${CLONE_PATH}/autojump \
       && SHELL=/bin/bash ./install.py

#TODO: install tmux plugins automatically
RUN    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm \
       && tmux source ~/.tmux.conf #need to install tmux plugins with `prefix+I` after login

#rust
RUN    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > ${CLONE_PATH}/rustup-init.sh \
       && chmod +x ${CLONE_PATH}/rustup-init.sh \
       && ${CLONE_PATH}/rustup-init.sh -y

RUN    git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf \
       && ~/.fzf/install #\
    #&& git clone --depth=1 https://github.com/amix/vimrc.git ~/.vim_runtime \
    #   && sh ~/.vim_runtime/install_awesome_vimrc.sh

RUN    ~/.cargo/bin/cargo install --git https://github.com/Peltoche/lsd.git --branch master \
    && ~/.cargo/bin/cargo install broot exa fd-find hexyl ripgrep sd bat procs gping bottom choose du-dust \
    && ~/.cargo/bin/cargo install onefetch tealdeer pastel hyperfine git-delta xh zoxide #zoxide need to configure
    #&& ~/.cargo/bin/cargo install --git https://github.com/p-e-w/hegemon.git --branch master \
    #&& ~/.cargo/bin/cargo install --git https://github.com/ogham/dog.git --branch master \

#starship,manimlib,gor,mediainfo,ssh-chat
#sudo go get -u -v github.com/liamg/aminal \
#git clone --config transfer.fsckobjects=false --config receive.fsckobjects=false --config fetch.fsckobjects=false https://github.com/github/hub.git ${CLONE_PATH}/hub cd ${CLONE_PATH}/hub make install prefix=${APP_PATH}/hub ln -s ${APP_PATH}/hub/bin/hub ${BIN_PATH}/hub \
#git clone https://github.com/flok99/multitail ${CLONE_PATH}/multitail cd ${CLONE_PATH}/multitail mkdir build cd build cmake .. sudo make install \
#git-flow
#vim-plugins
#host
#FlameGraph
#https://github.com/alebcay/awesome-shell

#qt installer maybe need graphic window
# RUN    cd ${CLONE_PATH} \
       # && wget https://download.qt.io/official_releases/qt/5.12/5.12.11/qt-opensource-linux-x64-5.12.11.run \
       # && chmod +x qt-opensource-linux-x64-5.12.1.run \
       # && ./qt-opensource-linux-x64-5.12.1.run

# RUN    git clone https://github.com/lheric/GitlHEVCAnalyzer.git ${CLONE_PATH}/GitlHEVCAnalyzer \
       # && cd ${CLONE_PATH}/GitlHEVCAnalyzer \
       # && git submodule update --init --recursive \
       # && git submodule update --recursive \
       # && qmake -qt=qt5 GitlHEVCAnalyzer.pro -r "CONFIG+=Release" \
       # && make

#RUN    sudo sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" \
#    && git clone --depth=1 https://github.com/Bash-it/bash-it.git ${CLONE_PATH}/bash-it \
#       && cd ${CLONE_PATH} \
#       && ./bash-it/install.sh -s

#RUN    git clone https://github.com/ccache/ccache ${CLONE_PATH}/ccache \
#       && cd ${CLONE_PATH}/ccache \
#       && ./autogen.sh \
#       && ./configure --prefix=${APP_PATH}/ccache --with-libzstd-from-internet --with-libb2-from-internet \
#       && make -j 10 \
#       && make install \
#       && ln -s ${APP_PATH}/ccache/bin/ccache ${BIN_PATH}/ccache

#RUN    git clone https://github.com/flok99/multitail ${CLONE_PATH}/multitail \
#       && cd ${CLONE_PATH}/multitail \
#       && mkdir build \
#       && cd build \
#       && cmake .. \
#       && make install

#RUN    curl https://cht.sh/:cht.sh | tee ${APP_PATH}/bin/cht.sh \
#       && chmod +x ${APP_PATH}/bin/cht.sh

#RUN    curl https://raw.githubusercontent.com/denilsonsa/prettyping/master/prettyping | tee ${APP_PATH}/bin/prettyping \
#       && chmod +x ${APP_PATH}/bin/prettyping

#    && git clone https://github.com/neovim/neovim ${CLONE_PATH}/neovim \
#       && cd ${CLONE_PATH}/neovim \
#       && make CMAKE_INSTALL_PREFIX=${APP_PATH}/neovim \
#       && make install \
#       && ln -s ${APP_PATH}/neovim/bin/neovim ${BIN_PATH}/neovim \


USER root
CMD /usr/sbin/init
