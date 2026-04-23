#!/bin/bash

profrepurl=https://github.com/ProfNpc/api.git

if git rev-parse --git-dir > /dev/null 2>&1; then
	echo "Este é um diretório Git"
	echo "Vamos pegar o projeto api do professor"
	
	echo $profrepurl

	#pega o remote do aluno no formato "origin  https://github.com/<userio-github>/repo-aluno.git (fetch)"
	alunorepourl=`git remote -v | head -1`
	#Remove "origin" de alunorepourl
	alunorepourl=${alunorepourl/origin/}
	#Remove "(fetch)" de alunorepourl
	alunorepourl=${alunorepourl/"(fetch)"/}

	echo $alunorepourl

	#Cria commit com alteração ainda não commitadas
	echo "Adiciona alterações pendentes"
	git add .
	git commit -m "Alterações pendentes"

	#Renomeia o branch main
	git switch main

	numoldmain=`git branch | grep old-main | wc -l`
	nomebranch=`echo old-main${numoldmain}`


	git branch -m ${nomebranch}

	#Cria um novo branch main(local) a partir de profrepo
	git checkout --orphan main

	git reset --hard

	numproforigin=`git remote -v | grep prof-origin | wc -l`
	if [ "$numproforigin" -eq "0" ]; then
		git remote add prof-origin ${profrepurl}
	fi


	git pull prof-origin main

	#Agora remove a referencia para o repo remoto profrepo
	#deixando apenas origin apontando para alunorepo
	git remote remove prof-origin

	#git remote add origin ${alunorepourl}

	#Sobreescreve todo o conteudo do repositorio remoto com o conteudo que veio de profrepo
	git push --force origin main


	#git branch -D old-main
	
else
	echo "Not a Git repository"
	
	numapidir=`ls -d api* | grep api | wc -l`
	
	if [ "$numapidir" -eq "0" ]; then
		echo "Não tem diretório api, git clone"
		git clone $profrepurl
		cd api
	else
		echo "Tem diretório api, git clone apiN"
		nomenovadirapi=`echo api${numapidir}`
		git clone $profrepurl $nomenovadirapi
		cd $nomenovadirapi
	fi
	
	read -p "Qual é o seu nome? " username
	read -p "Qual é o seu e-mail? " useremail
	
	git config --local user.name $username
	git config --local user.email $useremail
	git config --local init.defaultBranch main
	git config --local core.autocrlf true
	git config --local core.safecrlf warn
	
	read -p "Qual é endereço do seu repositório(GitHub)? " githubrepo
	git remote set-url origin ${githubrepo}
	git push --force origin main
	
fi




