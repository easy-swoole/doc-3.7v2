<?php


namespace App\HttpController;


use EasySwoole\Http\AbstractInterface\Controller;
use EasySwoole\ParserDown\ParserDown;

class Index extends Controller
{

    public function index()
    {
        $file = EASYSWOOLE_ROOT.'/Cn/index.html';
        $this->response()->write(file_get_contents($file));
    }



    protected function actionNotFound(?string $action)
    {
        $path = $this->request()->getUri()->getPath();
        $info = pathinfo($path);
        $path = $info['dirname'];
        if ($info['filename'] != 'index') {
            $path = rtrim($path, '/') . "/" . $info['filename'];
        }
        $docFile = EASYSWOOLE_ROOT .'/Cn'. $path.'.md';
        if (file_exists($docFile)) {
            $sideBar = EASYSWOOLE_ROOT.'/Cn/sideBar.md';
            $sideBar = (new ParserDown())->parse(file_get_contents($sideBar));
            $sideBar = str_replace(".md",'.html',$sideBar);
            $docContent = file_get_contents($docFile);
            $docContent = (new ParserDown())->parse($docContent);
            $tpl = EASYSWOOLE_ROOT .'/Cn/contentPage.tpl';
            $tpl = file_get_contents($tpl);
            $tpl = str_replace('{$sideBar}',$sideBar,$tpl);
            $tpl = str_replace('{$page.html}',$docContent,$tpl);
            $this->response()->write($tpl);
        }else{
            $this->response()->withStatus(404);
        }
    }
}