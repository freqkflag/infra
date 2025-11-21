import { createRouter, createWebHistory } from 'vue-router'
import { useAuthStore } from '@/stores/auth'

const router = createRouter({
  history: createWebHistory(),
  routes: [
    {
      path: '/',
      name: 'home',
      component: () => import('@/views/Dashboard.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/login',
      name: 'login',
      component: () => import('@/views/Login.vue'),
    },
    {
      path: '/register',
      name: 'register',
      component: () => import('@/views/Register.vue'),
    },
    {
      path: '/profile/:id?',
      name: 'profile',
      component: () => import('@/views/Profile.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/groups',
      name: 'groups',
      component: () => import('@/views/Groups.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/groups/:id',
      name: 'group-detail',
      component: () => import('@/views/GroupDetail.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/events',
      name: 'events',
      component: () => import('@/views/Events.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/events/:id',
      name: 'event-detail',
      component: () => import('@/views/EventDetail.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/messages',
      name: 'messages',
      component: () => import('@/views/Messages.vue'),
      meta: { requiresAuth: true },
    },
    {
      path: '/search',
      name: 'search',
      component: () => import('@/views/Search.vue'),
      meta: { requiresAuth: true },
    },
  ],
})

router.beforeEach((to, from, next) => {
  const authStore = useAuthStore()
  
  if (to.meta.requiresAuth && !authStore.isAuthenticated) {
    next({ name: 'login' })
  } else if ((to.name === 'login' || to.name === 'register') && authStore.isAuthenticated) {
    next({ name: 'home' })
  } else {
    next()
  }
})

export default router

