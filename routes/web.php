<?php

use Illuminate\Support\Facades\Route;
use Illuminate\Support\Facades\Schema;
use Illuminate\Support\Facades\Artisan;
use App\Models\User;

Route::get('/', function () {
    return view('welcome');
});

Route::get('/ping', function () {
    if (!Schema::hasTable('users')) {
        Artisan::call('migrate', ['--force' => true]);
    }
    return "ok, users=" . User::count();
});




Route::get('/test-write', function () {
    \App\Models\User::firstOrCreate(
        ['email' => 'demo@example.com'],
        ['name' => 'Demo', 'password' => bcrypt('Password123!')]
    );
    return 'wrote';
});

Route::get('/test-count', function () {
    return 'users=' . \App\Models\User::count();
});
