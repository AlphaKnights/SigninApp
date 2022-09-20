<template>
    <div id="app">
        <div class="container">
            <h1>{{title}}</h1>
            <div style="margin-bottom: 5px;" id="form" v-if="page=='signin-page'">
                <h3>Name (First and Last):</h3>
                <input class="text-input" v-model="user" type="text">
                <h3>Student ID:</h3>
                <input class="text-input" v-model="id" type="text">
                <h3>Grade:</h3>
                <input class="text-input" v-model="grade" type="text">
                <!-- < -->
                <!-- <div class="SaveLogin">
                    <div class="center inline">
                        <h3>Save Login?</h3>
                    </div>
                    <input class="inline" v-model="saveLogin" type="checkbox">
                </div> -->
            </div>
            <div id="signed-in-page" v-if="page=='signed-in-page'">
                <!-- <h2>Success!</h2> -->
                <h3 style="margin-bottom: 10px;">You signed in successfully!<br> Please check in when you enter the meeting and check out when you leave!</h3>
                <button class="clock-button" style="margin-bottom: 10px;" @click="toggleCheckIn()" v-if="page=='signed-in-page'" v-bind:class="{'green': checkedIn=='false', 'red': checkedIn=='true', 'loading': checkedIn=='loading'}">{{checkedInText}}</button>
            </div>
            <button class="submit-button" @click="login()" v-if="page=='signin-page'">Sign in</button>
            <button class="submit-button" @click="logout()" v-if="page=='signed-in-page'">Sign out</button>
        </div>
    </div>
  </template>
  
  <script>
  export default {
    user: 'app',
    data() {
        return {
            user: '',
            id: '',
            grade: '',
            signedIn: false,
            checkedIn: 'false',
            checkedInText: 'Check in',
            page: 'signin-page',
            title: 'Sign in',
            api_url: 'https://api.alphaknights.xyz/'
        }
    },
  
    created() {
        if (document.cookie == "") return
        var cookies = document.cookie
            .split(';')
            .map(cookie => cookie.split('='))
            .reduce((accumulator, [key, value]) => ({ ...accumulator, [key.trim()]: decodeURIComponent(value) }), {});
        for (const key of Object.keys(cookies)) {
            if (key == 'user') {
                this.$data.user = cookies[key]
            }
            else if (key == 'id') {
                this.$data.id = cookies[key]
            }
            else if (key == 'grade') {
                this.$data.grade = cookies[key]
            }
            else if (key == 'signedin') {
                if(cookies[key]=="true"){
                  this.$data.signedIn = true;
                  this.$data.page = 'signed-in-page'
                  this.$data.title = "Welcome " + this.user;
                }
            }
            else if (key == 'checkedin') {
                this.$data.checkedIn = cookies[key];
                if(this.$data.checkedIn=="loading"){
                    this.$data.checkedIn= 'false'
                    this.$data.checkedInText= 'Check in'
                }
                else if(this.$data.checkedIn=="true"){
                    this.$data.checkedInText= 'Check out'
                }
                else{
                    this.$data.checkedIn= 'false'
                    this.$data.checkedInText= 'Check in'
                }
            }
        }
    },
  
    methods: {
        dblogin(user, id, grade, callback){
            let response
            const reqOpt = {
                method: "POST",
                headers: {"Access-Control-Allow-Origin": this.api_url}
            }
            fetch(this.api_url+"/entry/?name=" + user + "&id=" + id + "&grade=" + grade, reqOpt)
                .then(async response => {
                    return await response.json()
                })
                .then(json =>{
                    callback(json)
            })
            return(response)
        },
  
        dblogout(user, id, grade, callback){
            let response
            const reqOpt = {
                method: "POST",
                headers: {"Access-Control-Allow-Origin": this.api_url}
            }
            fetch(this.api_url+"/exit/?name=" + user + "&id=" + id + "&grade=" + grade, reqOpt)
                .then(async response => {
                    return await response.json()
                })
                .then(json =>{
                    callback(json)
            })
            return(response)
        },
  
        login() {
            this.$data.page = 'signed-in-page'
            this.$data.signedIn=true
            this.updateCookies()
            this.$data.title = "Welcome " + this.user;
        },
  
        logout() {
            this.$data.page = 'signin-page'
            this.$data.saveLogin = this.saveLogin
            this.$data.title = "Sign in";
            this.$data.signedIn=false
            this.updateCookies()
        },

        toggleCheckIn(){
            if(this.checkedIn=="false"){
                this.checkedIn="loading"
                this.checkedInText = "loading"
                this.dblogin(this.user, this.id, this.grade, (d) => {
                    if(d['code']==0){
                        this.checkedIn="true"
                        this.checkedInText = "Check out"
                    }
                    else{
                        alert("There was an error["+d['code']+"]: "+d['reason'])
                    }
                    this.updateCookies();
                })
            }
            else if(this.checkedIn=="true"){
                this.checkedIn="loading"
                this.dblogout(this.user, this.id, this.grade, (d) => {
                    if(d['code']==0){
                        this.checkedIn="false"
                        this.checkedInText = "Check in"
                    }
                    this.updateCookies();
                })
            }
        },
  
        updateCookies() {
            document.cookie = 'user=' + this.user + ';Secure;SameSite=Strict;'
            document.cookie = 'id=' + this.id + ';Secure;SameSite=Strict;'
            document.cookie = 'grade=' + this.grade + ';Secure;SameSite=Strict;'
            if(this.signedIn){
              document.cookie = 'signedin=true;Secure;SameSite=Strict;'
            }
            else{
              document.cookie = 'signedin=false;Secure;SameSite=Strict;'
            }
            document.cookie = 'checkedin=' + this.checkedIn + ';Secure;SameSite=Strict;'
        }
    }
  }
  </script>
  
  <style>
  
  </style>
  