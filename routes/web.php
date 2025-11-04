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



