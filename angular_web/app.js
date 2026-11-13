angular.module('datingApp', ['ngRoute'])
    .config(['$routeProvider', function ($routeProvider) {
        $routeProvider
            .when('/', { template: '<p>Home</p>' })
            .when('/login', { template: '<p>Login</p>' })
            .when('/register', { template: '<p>Register</p>' })
            .otherwise({ redirectTo: '/' });
    }])
    .controller('MainCtrl', [function () {
        var vm = this;
        vm.title = 'Dating Web App';
    }]);
