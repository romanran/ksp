import Vue from 'vue'
import Router from 'vue-router'
import Home from '@/components/Home'
import Journal from '@/components/Journal'

Vue.use(Router)

export default new Router({
  routes: [
    {
      path: '/',
      name: 'home',
      component: Home
    },
    {
      path: '/journal/:name',
      name: 'journal',
      component: Journal
    }
  ]
})
